package com.servlink.servlink.service;

import com.servlink.servlink.dto.request.AvaliacaoRequest;
import com.servlink.servlink.dto.response.AvaliacaoResponse;
import java.util.List;

public interface AvaliacaoService {

    AvaliacaoResponse criar(AvaliacaoRequest request);

    List<AvaliacaoResponse> listarPorProfissional(Long profissionalId);
}
