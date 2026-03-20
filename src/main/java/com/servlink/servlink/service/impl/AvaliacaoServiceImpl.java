package com.servlink.servlink.service.impl;

import com.servlink.servlink.domain.entity.Avaliacao;
import com.servlink.servlink.domain.entity.Cliente;
import com.servlink.servlink.domain.entity.Profissional;
import com.servlink.servlink.dto.request.AvaliacaoRequest;
import com.servlink.servlink.dto.response.AvaliacaoResponse;
import com.servlink.servlink.mapper.AvaliacaoMapper;
import com.servlink.servlink.repository.AvaliacaoRepository;
import com.servlink.servlink.repository.ClienteRepository;
import com.servlink.servlink.repository.ProfissionalRepository;
import com.servlink.servlink.service.AvaliacaoService;
import jakarta.transaction.Transactional;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Service
public class AvaliacaoServiceImpl implements AvaliacaoService {

    private final AvaliacaoRepository avaliacaoRepository;
    private final ClienteRepository clienteRepository;
    private final ProfissionalRepository profissionalRepository;
    private final AvaliacaoMapper avaliacaoMapper;

    public AvaliacaoServiceImpl(
            AvaliacaoRepository avaliacaoRepository,
            ClienteRepository clienteRepository,
            ProfissionalRepository profissionalRepository,
            AvaliacaoMapper avaliacaoMapper) {
        this.avaliacaoRepository = avaliacaoRepository;
        this.clienteRepository = clienteRepository;
        this.profissionalRepository = profissionalRepository;
        this.avaliacaoMapper = avaliacaoMapper;
    }

    @Override
    @Transactional
    public AvaliacaoResponse criar(AvaliacaoRequest request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new IllegalStateException("Usuário não autenticado");
        }

        String email = authentication.getName();

        Cliente cliente = clienteRepository.findByUsuarioEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Cliente não encontrado"));

        boolean jaAvaliou = avaliacaoRepository.existsByClienteIdAndProfissionalId(
                cliente.getId(),
                request.getProfissionalId());

        if (jaAvaliou) {
            throw new IllegalArgumentException("Cliente já avaliou este profissional");
        }

        Profissional profissional = profissionalRepository.findById(request.getProfissionalId())
                .orElseThrow(() -> new IllegalArgumentException("Profissional não encontrado"));

        Avaliacao avaliacao = new Avaliacao();
        avaliacao.setCliente(cliente);
        avaliacao.setProfissional(profissional);
        avaliacao.setNota(request.getNota());
        avaliacao.setComentario(request.getComentario());
        avaliacao.setAtivo(true);

        Avaliacao salva = avaliacaoRepository.save(avaliacao);

        Double media = avaliacaoRepository.calcularMediaPorProfissional(profissional.getId());
        BigDecimal mediaBd = media == null
                ? null
                : BigDecimal.valueOf(media).setScale(2, RoundingMode.HALF_UP);
        profissional.setMediaAvaliacoes(mediaBd);
        profissionalRepository.save(profissional);

        return avaliacaoMapper.toResponse(salva);
    }

    @Override
    public List<AvaliacaoResponse> listarPorProfissional(Long profissionalId) {
        return avaliacaoRepository.findByProfissionalIdOrderByDataCriacaoDesc(profissionalId).stream()
                .map(avaliacaoMapper::toResponse)
                .collect(Collectors.toList());
    }
}
