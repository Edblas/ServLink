package com.servlink.servlink.service.impl;

import com.servlink.servlink.domain.entity.Candidatura;
import com.servlink.servlink.domain.entity.Cliente;
import com.servlink.servlink.domain.entity.Profissional;
import com.servlink.servlink.domain.entity.Usuario;
import com.servlink.servlink.domain.entity.Vaga;
import com.servlink.servlink.domain.enums.CandidaturaStatus;
import com.servlink.servlink.domain.enums.Role;
import com.servlink.servlink.domain.enums.VagaStatus;
import com.servlink.servlink.dto.response.CandidaturaResponse;
import com.servlink.servlink.mapper.CandidaturaMapper;
import com.servlink.servlink.repository.CandidaturaRepository;
import com.servlink.servlink.repository.ClienteRepository;
import com.servlink.servlink.repository.ProfissionalRepository;
import com.servlink.servlink.repository.UsuarioRepository;
import com.servlink.servlink.repository.VagaRepository;
import com.servlink.servlink.service.CandidaturaService;
import jakarta.transaction.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Service
public class CandidaturaServiceImpl implements CandidaturaService {

    private final CandidaturaRepository candidaturaRepository;
    private final VagaRepository vagaRepository;
    private final ProfissionalRepository profissionalRepository;
    private final ClienteRepository clienteRepository;
    private final UsuarioRepository usuarioRepository;
    private final CandidaturaMapper candidaturaMapper;

    public CandidaturaServiceImpl(
            CandidaturaRepository candidaturaRepository,
            VagaRepository vagaRepository,
            ProfissionalRepository profissionalRepository,
            ClienteRepository clienteRepository,
            UsuarioRepository usuarioRepository,
            CandidaturaMapper candidaturaMapper) {
        this.candidaturaRepository = candidaturaRepository;
        this.vagaRepository = vagaRepository;
        this.profissionalRepository = profissionalRepository;
        this.clienteRepository = clienteRepository;
        this.usuarioRepository = usuarioRepository;
        this.candidaturaMapper = candidaturaMapper;
    }

    @Override
    @Transactional
    public CandidaturaResponse candidatar(Long vagaId) {
        Usuario usuario = getUsuarioAtual(Role.PROFISSIONAL);
        Profissional profissional = profissionalRepository.findByUsuarioEmail(usuario.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("Profissional não encontrado"));

        Vaga vaga = vagaRepository.findById(vagaId)
                .orElseThrow(() -> new IllegalArgumentException("Vaga não encontrada"));

        if (vaga.getEmpresa() != null
                && vaga.getEmpresa().getUsuario() != null
                && vaga.getEmpresa().getUsuario().getId() != null
                && vaga.getEmpresa().getUsuario().getId().equals(usuario.getId())) {
            throw new IllegalArgumentException("Você não pode se candidatar na sua própria vaga");
        }

        if (vaga.getStatus() != VagaStatus.ABERTA) {
            throw new IllegalArgumentException("Vaga não está aberta para candidaturas");
        }

        boolean jaCandidatou = candidaturaRepository.existsByVagaIdAndProfissionalId(vagaId, profissional.getId());
        if (jaCandidatou) {
            throw new IllegalArgumentException("Candidatura duplicada");
        }

        Candidatura candidatura = new Candidatura();
        candidatura.setVaga(vaga);
        candidatura.setProfissional(profissional);
        candidatura.setDataCandidatura(LocalDateTime.now());
        candidatura.setStatus(CandidaturaStatus.PENDENTE);
        candidatura.setAtivo(true);

        Candidatura salva = candidaturaRepository.save(candidatura);
        return candidaturaMapper.toResponse(salva);
    }

    @Override
    public List<CandidaturaResponse> listarCandidatosDaVaga(Long vagaId) {
        Usuario usuario = getUsuarioAtual(Role.CLIENTE, Role.PROFISSIONAL);
        Cliente cliente = clienteRepository.findByUsuarioEmail(usuario.getEmail())
                .orElseGet(() -> {
                    Cliente novo = new Cliente();
                    novo.setUsuario(usuario);
                    novo.setAtivo(true);
                    return clienteRepository.save(novo);
                });

        Vaga vaga = vagaRepository.findById(vagaId)
                .orElseThrow(() -> new IllegalArgumentException("Vaga não encontrada"));

        if (!vaga.getEmpresa().getId().equals(cliente.getId())) {
            throw new AccessDeniedException("Acesso negado");
        }

        return candidaturaRepository.findByVagaIdOrderByDataCandidaturaDesc(vagaId).stream()
                .map(candidaturaMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<CandidaturaResponse> listarCandidaturasDoProfissional(Long profissionalId) {
        Usuario usuario = getUsuarioAtual(Role.PROFISSIONAL);
        Profissional profissional = profissionalRepository.findByUsuarioEmail(usuario.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("Profissional não encontrado"));

        if (!profissional.getId().equals(profissionalId)) {
            throw new AccessDeniedException("Acesso negado");
        }

        return candidaturaRepository.findByProfissionalIdOrderByDataCandidaturaDesc(profissionalId).stream()
                .map(candidaturaMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public CandidaturaResponse atualizarStatus(Long candidaturaId, CandidaturaStatus status) {
        Usuario usuario = getUsuarioAtual(Role.CLIENTE, Role.PROFISSIONAL);
        Cliente cliente = clienteRepository.findByUsuarioEmail(usuario.getEmail())
                .orElseGet(() -> {
                    Cliente novo = new Cliente();
                    novo.setUsuario(usuario);
                    novo.setAtivo(true);
                    return clienteRepository.save(novo);
                });

        Candidatura candidatura = candidaturaRepository.findById(candidaturaId)
                .orElseThrow(() -> new IllegalArgumentException("Candidatura não encontrada"));

        Vaga vaga = candidatura.getVaga();
        if (!vaga.getEmpresa().getId().equals(cliente.getId())) {
            throw new AccessDeniedException("Acesso negado");
        }

        if (vaga.getStatus() == VagaStatus.CANCELADA) {
            throw new IllegalArgumentException("Vaga cancelada");
        }

        if (status == CandidaturaStatus.ACEITO) {
            if (vaga.getStatus() == VagaStatus.FECHADA) {
                throw new IllegalArgumentException("Vaga já fechada");
            }
            candidatura.setStatus(CandidaturaStatus.ACEITO);
            vaga.setStatus(VagaStatus.FECHADA);
            candidaturaRepository.recusarOutrasCandidaturasDaVaga(vaga.getId(), candidatura.getId());
        } else if (status == CandidaturaStatus.RECUSADO) {
            candidatura.setStatus(CandidaturaStatus.RECUSADO);
        } else {
            candidatura.setStatus(CandidaturaStatus.PENDENTE);
        }

        Candidatura salva = candidaturaRepository.save(candidatura);
        return candidaturaMapper.toResponse(salva);
    }

    private Usuario getUsuarioAtual(Role... allowedRoles) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new IllegalStateException("Usuário não autenticado");
        }

        String email = authentication.getName();
        Usuario usuario = usuarioRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));

        boolean allowed = false;
        for (Role role : allowedRoles) {
            if (usuario.getRole() == role) {
                allowed = true;
                break;
            }
        }
        if (!allowed) {
            throw new AccessDeniedException("Acesso negado");
        }

        return usuario;
    }
}
