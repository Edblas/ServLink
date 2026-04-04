package com.servlink.servlink.service.impl;

import com.servlink.servlink.domain.entity.Categoria;
import com.servlink.servlink.domain.entity.Cidade;
import com.servlink.servlink.domain.entity.Cliente;
import com.servlink.servlink.domain.entity.Usuario;
import com.servlink.servlink.domain.entity.Vaga;
import com.servlink.servlink.domain.enums.VagaStatus;
import com.servlink.servlink.domain.enums.VagaTipo;
import com.servlink.servlink.domain.enums.VagaUrgencia;
import com.servlink.servlink.dto.request.VagaRequest;
import com.servlink.servlink.dto.response.VagaResponse;
import com.servlink.servlink.mapper.VagaMapper;
import com.servlink.servlink.repository.CandidaturaRepository;
import com.servlink.servlink.repository.CategoriaRepository;
import com.servlink.servlink.repository.CidadeRepository;
import com.servlink.servlink.repository.ClienteRepository;
import com.servlink.servlink.repository.UsuarioRepository;
import com.servlink.servlink.repository.VagaRepository;
import com.servlink.servlink.service.VagaService;
import jakarta.transaction.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

@Service
public class VagaServiceImpl implements VagaService {

    private final VagaRepository vagaRepository;
    private final ClienteRepository clienteRepository;
    private final UsuarioRepository usuarioRepository;
    private final CidadeRepository cidadeRepository;
    private final CategoriaRepository categoriaRepository;
    private final VagaMapper vagaMapper;
    private final CandidaturaRepository candidaturaRepository;

    public VagaServiceImpl(
            VagaRepository vagaRepository,
            ClienteRepository clienteRepository,
            UsuarioRepository usuarioRepository,
            CidadeRepository cidadeRepository,
            CategoriaRepository categoriaRepository,
            VagaMapper vagaMapper,
            CandidaturaRepository candidaturaRepository) {
        this.vagaRepository = vagaRepository;
        this.clienteRepository = clienteRepository;
        this.usuarioRepository = usuarioRepository;
        this.cidadeRepository = cidadeRepository;
        this.categoriaRepository = categoriaRepository;
        this.vagaMapper = vagaMapper;
        this.candidaturaRepository = candidaturaRepository;
    }

    @Override
    @Transactional
    public VagaResponse criar(VagaRequest request) {
        Cliente empresa = getOrCreateClienteAtual();

        Cidade cidade = cidadeRepository.findById(request.getCidadeId())
                .orElseThrow(() -> new IllegalArgumentException("Cidade não encontrada"));

        Categoria categoria = categoriaRepository.findById(request.getCategoriaId())
                .orElseThrow(() -> new IllegalArgumentException("Categoria não encontrada"));

        Vaga vaga = new Vaga();
        vaga.setEmpresa(empresa);
        vaga.setTitulo(request.getTitulo());
        vaga.setDescricao(request.getDescricao());
        vaga.setValor(request.getValor());
        vaga.setCidade(cidade);
        vaga.setDataTrabalho(request.getDataTrabalho());
        vaga.setUrgencia(request.getUrgencia() == null ? VagaUrgencia.FLEXIVEL : request.getUrgencia());
        vaga.setTipo(request.getTipo() == null ? VagaTipo.BICO : request.getTipo());
        vaga.setStatus(VagaStatus.ABERTA);
        vaga.setCategoria(categoria);
        vaga.setAtivo(true);
        vaga.setExpiraEm(calculateExpiraEm(request, vaga.getTipo()));

        Vaga salva = vagaRepository.save(vaga);
        VagaResponse response = vagaMapper.toResponse(salva);
        response.setCandidaturasCount(0L);
        return response;
    }

    @Override
    public List<VagaResponse> listar() {
        List<VagaResponse> responses = vagaRepository.findAllAtivasNaoExpiradas(LocalDateTime.now()).stream()
                .map(vagaMapper::toResponse)
                .collect(Collectors.toList());
        applyCandidaturasCount(responses);
        return responses;
    }

    @Override
    public VagaResponse obter(Long id) {
        Vaga vaga = vagaRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Vaga não encontrada"));
        if (vaga.getAtivo() == null || !vaga.getAtivo()) {
            throw new IllegalArgumentException("Vaga não encontrada");
        }
        if (vaga.getStatus() == VagaStatus.CANCELADA || vaga.getStatus() == VagaStatus.EXPIRADA) {
            throw new IllegalArgumentException("Vaga não encontrada");
        }
        if (vaga.getExpiraEm() != null && vaga.getExpiraEm().isBefore(LocalDateTime.now())) {
            vaga.setStatus(VagaStatus.EXPIRADA);
            vagaRepository.save(vaga);
            throw new IllegalArgumentException("Vaga não encontrada");
        }
        VagaResponse response = vagaMapper.toResponse(vaga);
        response.setCandidaturasCount(candidaturaRepository.countByVagaId(id));
        return response;
    }

    @Override
    public List<VagaResponse> listarPorEmpresa(Long empresaId) {
        validarEmpresaAtual(empresaId);
        List<VagaResponse> responses = vagaRepository.findByEmpresaIdOrderByDataCriacaoDesc(empresaId).stream()
                .map(vagaMapper::toResponse)
                .collect(Collectors.toList());
        applyCandidaturasCount(responses);
        return responses;
    }

    @Override
    @Transactional
    public void apagar(Long id) {
        Cliente cliente = getOrCreateClienteAtual();
        Vaga vaga = vagaRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Vaga não encontrada"));
        if (!vaga.getEmpresa().getId().equals(cliente.getId())) {
            throw new AccessDeniedException("Acesso negado");
        }
        vaga.setStatus(VagaStatus.CANCELADA);
        vaga.setAtivo(false);
        vagaRepository.save(vaga);
    }

    private void applyCandidaturasCount(List<VagaResponse> responses) {
        if (responses.isEmpty()) return;
        List<Long> ids = responses.stream().map(VagaResponse::getId).toList();
        List<Object[]> rows = candidaturaRepository.countByVagaIds(ids);
        Map<Long, Long> counts = rows.stream().collect(Collectors.toMap(
                r -> (Long) r[0],
                r -> (Long) r[1]
        ));
        for (VagaResponse response : responses) {
            response.setCandidaturasCount(counts.getOrDefault(response.getId(), 0L));
        }
    }

    private LocalDateTime calculateExpiraEm(VagaRequest request, VagaTipo tipo) {
        Integer dias = request.getDiasExpiracao();
        if (dias != null && dias > 0 && dias <= 365) {
            return LocalDateTime.now().plusDays(dias);
        }
        if (tipo == VagaTipo.BICO) {
            return LocalDateTime.now().plusDays(7);
        }
        return LocalDateTime.now().plusDays(30);
    }

    private void validarEmpresaAtual(Long empresaId) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new IllegalStateException("Usuário não autenticado");
        }

        Object principal = authentication.getPrincipal();
        if (principal instanceof UserDetails userDetails) {
            Usuario usuario = usuarioRepository.findByEmail(userDetails.getUsername())
                    .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));
            if (usuario.getRole() != com.servlink.servlink.domain.enums.Role.CLIENTE
                    && usuario.getRole() != com.servlink.servlink.domain.enums.Role.PROFISSIONAL) {
                throw new AccessDeniedException("Acesso negado");
            }
        }

        Cliente cliente = clienteRepository.findByUsuarioEmail(authentication.getName())
                .orElseThrow(() -> new IllegalArgumentException("Cliente não encontrado"));

        if (!cliente.getId().equals(empresaId)) {
            throw new AccessDeniedException("Acesso negado");
        }
    }

    private Cliente getOrCreateClienteAtual() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new IllegalStateException("Usuário não autenticado");
        }

        String email = authentication.getName();

        return clienteRepository.findByUsuarioEmail(email).orElseGet(() -> {
            Usuario usuario = usuarioRepository.findByEmail(email)
                    .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));

            if (usuario.getRole() != com.servlink.servlink.domain.enums.Role.CLIENTE
                    && usuario.getRole() != com.servlink.servlink.domain.enums.Role.PROFISSIONAL) {
                throw new AccessDeniedException("Apenas CLIENTE ou PROFISSIONAL pode criar vaga");
            }

            Cliente cliente = new Cliente();
            cliente.setUsuario(usuario);
            cliente.setAtivo(true);
            return clienteRepository.save(cliente);
        });
    }
}
