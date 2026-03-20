package com.servlink.servlink.service.impl;

import com.servlink.servlink.domain.entity.Cidade;
import com.servlink.servlink.dto.request.CidadeRequest;
import com.servlink.servlink.dto.response.CidadeResponse;
import com.servlink.servlink.mapper.CidadeMapper;
import com.servlink.servlink.repository.CidadeRepository;
import com.servlink.servlink.service.CidadeService;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;

@Service
public class CidadeServiceImpl implements CidadeService {

    private final CidadeRepository cidadeRepository;
    private final CidadeMapper cidadeMapper;

    public CidadeServiceImpl(CidadeRepository cidadeRepository, CidadeMapper cidadeMapper) {
        this.cidadeRepository = cidadeRepository;
        this.cidadeMapper = cidadeMapper;
    }

    @Override
    public CidadeResponse criar(CidadeRequest request) {
        Cidade cidade = cidadeMapper.toEntity(request);
        cidade.setAtivo(true);
        Cidade salva = cidadeRepository.save(cidade);
        return cidadeMapper.toResponse(salva);
    }

    @Override
    public List<CidadeResponse> listarTodas() {
        return cidadeRepository.findAll().stream()
                .map(cidadeMapper::toResponse)
                .collect(Collectors.toList());
    }
}
