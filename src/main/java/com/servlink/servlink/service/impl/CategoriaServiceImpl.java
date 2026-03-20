package com.servlink.servlink.service.impl;

import com.servlink.servlink.domain.entity.Categoria;
import com.servlink.servlink.dto.request.CategoriaRequest;
import com.servlink.servlink.dto.response.CategoriaResponse;
import com.servlink.servlink.mapper.CategoriaMapper;
import com.servlink.servlink.repository.CategoriaRepository;
import com.servlink.servlink.service.CategoriaService;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;

@Service
public class CategoriaServiceImpl implements CategoriaService {

    private final CategoriaRepository categoriaRepository;
    private final CategoriaMapper categoriaMapper;

    public CategoriaServiceImpl(CategoriaRepository categoriaRepository, CategoriaMapper categoriaMapper) {
        this.categoriaRepository = categoriaRepository;
        this.categoriaMapper = categoriaMapper;
    }

    @Override
    public CategoriaResponse criar(CategoriaRequest request) {
        Categoria categoria = categoriaMapper.toEntity(request);
        categoria.setAtivo(true);
        Categoria salva = categoriaRepository.save(categoria);
        return categoriaMapper.toResponse(salva);
    }

    @Override
    public List<CategoriaResponse> listarTodas() {
        return categoriaRepository.findAll().stream()
                .map(categoriaMapper::toResponse)
                .collect(Collectors.toList());
    }
}
