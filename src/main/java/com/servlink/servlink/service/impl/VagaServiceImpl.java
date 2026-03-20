package com.servlink.servlink.service.impl;

import com.servlink.servlink.domain.entity.Categoria;
import com.servlink.servlink.domain.entity.Cidade;
import com.servlink.servlink.domain.entity.Cliente;
import com.servlink.servlink.domain.entity.Usuario;
import com.servlink.servlink.domain.entity.Vaga;
import com.servlink.servlink.domain.enums.VagaStatus;
import com.servlink.servlink.dto.request.VagaRequest;
import com.servlink.servlink.dto.response.VagaResponse;
import com.servlink.servlink.mapper.VagaMapper;
import com.servlink.servlink.repository.CategoriaRepository;
import com.servlink.servlink.repository.CidadeRepository;
import com.servlink.servlink.repository.ClienteRepository;
import com.servlink.servlink.repository.UsuarioRepository;
import com.servlink.servlink.repository.VagaRepository;
import com.servlink.servlink.service.VagaService;
import jakarta.transaction.Transactional;
import java.util.List;
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

    public VagaServiceImpl(
            VagaRepository vagaRepository,
            ClienteRepository clienteRepository,
            UsuarioRepository usuarioRepository,
            CidadeRepository cidadeRepository,
            CategoriaRepository categoriaRepository,
            VagaMapper vagaMapper) {
        this.vagaRepository = vagaRepository;
        this.clienteRepository = clienteRepository;
        this.usuarioRepository = usuarioRepository;
        this.cidadeRepository = cidadeRepository;
        this.categoriaRepository = categoriaRepository;
        this.vagaMapper = vagaMapper;
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
        vaga.setStatus(VagaStatus.ABERTA);
        vaga.setCategoria(categoria);
        vaga.setAtivo(true);

        Vaga salva = vagaRepository.save(vaga);
        return vagaMapper.toResponse(salva);
    }

    @Override
    public List<VagaResponse> listar() {
        return vagaRepository.findAllByOrderByDataCriacaoDesc().stream()
                .map(vagaMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public VagaResponse obter(Long id) {
        Vaga vaga = vagaRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Vaga não encontrada"));
        return vagaMapper.toResponse(vaga);
    }

    @Override
    public List<VagaResponse> listarPorEmpresa(Long empresaId) {
        validarEmpresaAtual(empresaId);
        return vagaRepository.findByEmpresaIdOrderByDataCriacaoDesc(empresaId).stream()
                .map(vagaMapper::toResponse)
                .collect(Collectors.toList());
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
            if (usuario.getRole() != com.servlink.servlink.domain.enums.Role.CLIENTE) {
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

            if (usuario.getRole() != com.servlink.servlink.domain.enums.Role.CLIENTE) {
                throw new AccessDeniedException("Apenas CLIENTE pode criar vaga");
            }

            Cliente cliente = new Cliente();
            cliente.setUsuario(usuario);
            cliente.setAtivo(true);
            return clienteRepository.save(cliente);
        });
    }
}

