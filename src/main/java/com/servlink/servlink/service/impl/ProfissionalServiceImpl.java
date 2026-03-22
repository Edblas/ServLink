package com.servlink.servlink.service.impl;

import com.servlink.servlink.domain.entity.Categoria;
import com.servlink.servlink.domain.entity.Cidade;
import com.servlink.servlink.domain.entity.Profissional;
import com.servlink.servlink.domain.entity.Usuario;
import com.servlink.servlink.domain.enums.Plano;
import com.servlink.servlink.domain.enums.Role;
import com.servlink.servlink.dto.request.ProfissionalPerfilRequest;
import com.servlink.servlink.dto.request.ProfissionalRequest;
import com.servlink.servlink.dto.response.ProfissionalResponse;
import com.servlink.servlink.mapper.ProfissionalMapper;
import com.servlink.servlink.repository.CategoriaRepository;
import com.servlink.servlink.repository.CidadeRepository;
import com.servlink.servlink.repository.ProfissionalRepository;
import com.servlink.servlink.repository.UsuarioRepository;
import com.servlink.servlink.service.ProfissionalService;
import jakarta.transaction.Transactional;
import java.math.BigDecimal;
import java.util.Optional;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

@Service
public class ProfissionalServiceImpl implements ProfissionalService {

    private final ProfissionalRepository profissionalRepository;
    private final UsuarioRepository usuarioRepository;
    private final CidadeRepository cidadeRepository;
    private final CategoriaRepository categoriaRepository;
    private final ProfissionalMapper profissionalMapper;

    public ProfissionalServiceImpl(
            ProfissionalRepository profissionalRepository,
            UsuarioRepository usuarioRepository,
            CidadeRepository cidadeRepository,
            CategoriaRepository categoriaRepository,
            ProfissionalMapper profissionalMapper) {
        this.profissionalRepository = profissionalRepository;
        this.usuarioRepository = usuarioRepository;
        this.cidadeRepository = cidadeRepository;
        this.categoriaRepository = categoriaRepository;
        this.profissionalMapper = profissionalMapper;
    }

    @Override
    @Transactional
    public ProfissionalResponse criar(ProfissionalRequest request) {
        Usuario usuario = usuarioRepository.findById(request.getUsuarioId())
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));

        if (usuario.getRole() != Role.PROFISSIONAL) {
            throw new IllegalArgumentException("Usuário precisa ter perfil PROFISSIONAL");
        }

        Cidade cidade = cidadeRepository.findById(request.getCidadeId())
                .orElseThrow(() -> new IllegalArgumentException("Cidade não encontrada"));

        Categoria categoria = categoriaRepository.findById(request.getCategoriaId())
                .orElseThrow(() -> new IllegalArgumentException("Categoria não encontrada"));

        Profissional profissional = new Profissional();
        profissional.setUsuario(usuario);
        profissional.setDescricao(request.getDescricao());
        profissional.setFotoUrl(request.getFotoUrl());
        profissional.setAnosExperiencia(request.getAnosExperiencia());
        profissional.setBairro(request.getBairro());
        profissional.setPlano(request.getPlano());
        profissional.setCidade(cidade);
        profissional.setCategoria(categoria);
        profissional.setMediaAvaliacoes(BigDecimal.ZERO);
        profissional.setAtivo(true);

        Profissional salvo = profissionalRepository.save(profissional);
        return profissionalMapper.toResponse(salvo);
    }

    @Override
    @Transactional
    @PreAuthorize("hasRole('PROFISSIONAL')")
    public ProfissionalResponse criarOuObterProfissionalAtual() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new IllegalStateException("Usuário não autenticado");
        }

        String email = authentication.getName();

        Optional<Profissional> existente = profissionalRepository.findByUsuarioEmail(email);
        if (existente.isPresent()) {
            return profissionalMapper.toResponse(existente.get());
        }

        Usuario usuario = usuarioRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));

        if (usuario.getRole() != Role.PROFISSIONAL) {
            throw new IllegalArgumentException("Usuário precisa ter perfil PROFISSIONAL");
        }

        Profissional profissional = new Profissional();
        profissional.setUsuario(usuario);
        profissional.setDescricao("Atualize seu perfil");
        profissional.setPlano(Plano.BASICO);
        profissional.setMediaAvaliacoes(BigDecimal.ZERO);
        profissional.setAtivo(true);

        Profissional salvo = profissionalRepository.save(profissional);
        return profissionalMapper.toResponse(salvo);
    }

    @Override
    @PreAuthorize("hasRole('PROFISSIONAL')")
    public ProfissionalResponse obterProfissionalAtual() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new IllegalStateException("Usuário não autenticado");
        }

        String email = authentication.getName();

        Profissional profissional = profissionalRepository.findByUsuarioEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Profissional não encontrado"));

        return profissionalMapper.toResponse(profissional);
    }

    @Override
    @Transactional
    @PreAuthorize("hasRole('PROFISSIONAL')")
    public ProfissionalResponse atualizarProfissionalAtual(ProfissionalPerfilRequest request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new IllegalStateException("Usuário não autenticado");
        }

        String email = authentication.getName();

        Profissional profissional = profissionalRepository.findByUsuarioEmail(email)
                .orElseGet(() -> {
                    Usuario usuario = usuarioRepository.findByEmail(email)
                            .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));

                    if (usuario.getRole() != Role.PROFISSIONAL) {
                        throw new IllegalArgumentException("Usuário precisa ter perfil PROFISSIONAL");
                    }

                    Profissional novo = new Profissional();
                    novo.setUsuario(usuario);
                    novo.setDescricao("Atualize seu perfil");
                    novo.setPlano(Plano.BASICO);
                    novo.setMediaAvaliacoes(BigDecimal.ZERO);
                    novo.setAtivo(true);
                    return profissionalRepository.save(novo);
                });

        if (request.getDescricao() != null) {
            String descricao = request.getDescricao().trim();
            if (descricao.isEmpty()) {
                throw new IllegalArgumentException("Descrição não pode ser vazia");
            }
            profissional.setDescricao(descricao);
        }

        if (request.getFotoUrl() != null) {
            String fotoUrl = request.getFotoUrl().trim();
            profissional.setFotoUrl(fotoUrl.isEmpty() ? null : fotoUrl);
        }

        if (request.getBairro() != null) {
            String bairro = request.getBairro().trim();
            profissional.setBairro(bairro.isEmpty() ? null : bairro);
        }

        if (request.getAnosExperiencia() != null) {
            profissional.setAnosExperiencia(request.getAnosExperiencia());
        }

        if (request.getCidadeId() != null) {
            Cidade cidade = cidadeRepository.findById(request.getCidadeId())
                    .orElseThrow(() -> new IllegalArgumentException("Cidade não encontrada"));
            profissional.setCidade(cidade);
        }

        if (request.getCategoriaId() != null) {
            Categoria categoria = categoriaRepository.findById(request.getCategoriaId())
                    .orElseThrow(() -> new IllegalArgumentException("Categoria não encontrada"));
            profissional.setCategoria(categoria);
        }

        Profissional salvo = profissionalRepository.save(profissional);
        return profissionalMapper.toResponse(salvo);
    }

    @Override
    public Page<ProfissionalResponse> buscar(Long cidadeId, Long categoriaId, String q, String bairro, int pagina, int tamanho) {
        Sort sort = Sort.by(
                Sort.Order.desc("plano"),
                Sort.Order.desc("mediaAvaliacoes"));

        Pageable pageable = PageRequest.of(pagina, tamanho, sort);

        String query = q == null || q.isBlank() ? null : q.trim();
        String bairroFiltro = bairro == null || bairro.isBlank() ? null : bairro.trim();

        return profissionalRepository.search(cidadeId, categoriaId, query, bairroFiltro, pageable)
                .map(profissionalMapper::toResponse);
    }
}
