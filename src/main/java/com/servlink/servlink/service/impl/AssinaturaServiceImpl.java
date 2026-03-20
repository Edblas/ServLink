package com.servlink.servlink.service.impl;

import com.servlink.servlink.domain.entity.Assinatura;
import com.servlink.servlink.domain.entity.Profissional;
import com.servlink.servlink.domain.enums.AssinaturaStatus;
import com.servlink.servlink.dto.request.AssinaturaRequest;
import com.servlink.servlink.dto.response.AssinaturaResponse;
import com.servlink.servlink.mapper.AssinaturaMapper;
import com.servlink.servlink.repository.AssinaturaRepository;
import com.servlink.servlink.repository.ProfissionalRepository;
import com.servlink.servlink.service.AssinaturaService;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

@Service
public class AssinaturaServiceImpl implements AssinaturaService {

    private final AssinaturaRepository assinaturaRepository;
    private final ProfissionalRepository profissionalRepository;
    private final AssinaturaMapper assinaturaMapper;

    public AssinaturaServiceImpl(
            AssinaturaRepository assinaturaRepository,
            ProfissionalRepository profissionalRepository,
            AssinaturaMapper assinaturaMapper) {
        this.assinaturaRepository = assinaturaRepository;
        this.profissionalRepository = profissionalRepository;
        this.assinaturaMapper = assinaturaMapper;
    }

    @Override
    @Transactional
    public AssinaturaResponse criar(AssinaturaRequest request) {
        Profissional profissional = profissionalRepository.findById(request.getProfissionalId())
                .orElseThrow(() -> new IllegalArgumentException("Profissional não encontrado"));

        Assinatura assinatura = new Assinatura();
        assinatura.setProfissional(profissional);
        assinatura.setPlano(request.getPlano());
        assinatura.setValor(request.getValor());
        assinatura.setStatus(AssinaturaStatus.ATIVA);
        assinatura.setDataInicio(request.getDataInicio());
        assinatura.setDataFim(request.getDataFim());
        assinatura.setAtivo(true);

        Assinatura salva = assinaturaRepository.save(assinatura);
        return assinaturaMapper.toResponse(salva);
    }
}
