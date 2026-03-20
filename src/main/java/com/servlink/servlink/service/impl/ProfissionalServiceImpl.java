package com.servlink.servlink.service.impl;

import com.servlink.servlink.domain.entity.Categoria;
import com.servlink.servlink.domain.entity.Cidade;
import com.servlink.servlink.domain.entity.Profissional;
import com.servlink.servlink.domain.entity.Usuario;
import com.servlink.servlink.domain.enums.Role;
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
        profissional.setPlano(request.getPlano());
        profissional.setCidade(cidade);
        profissional.setCategoria(categoria);
        profissional.setMediaAvaliacoes(BigDecimal.ZERO);
        profissional.setAtivo(true);

        Profissional salvo = profissionalRepository.save(profissional);
        return profissionalMapper.toResponse(salvo);
    }

    @Override
    public Page<ProfissionalResponse> buscar(Long cidadeId, Long categoriaId, int pagina, int tamanho) {
        Sort sort = Sort.by(
                Sort.Order.desc("plano"),
                Sort.Order.desc("mediaAvaliacoes"));

        Pageable pageable = PageRequest.of(pagina, tamanho, sort);

        return profissionalRepository.search(cidadeId, categoriaId, pageable)
                .map(profissionalMapper::toResponse);
    }
}
