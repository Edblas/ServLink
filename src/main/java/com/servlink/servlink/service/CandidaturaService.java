package com.servlink.servlink.service;

import com.servlink.servlink.dto.response.CandidaturaResponse;
import com.servlink.servlink.domain.enums.CandidaturaStatus;
import java.util.List;

public interface CandidaturaService {

    CandidaturaResponse candidatar(Long vagaId);

    List<CandidaturaResponse> listarCandidatosDaVaga(Long vagaId);

    List<CandidaturaResponse> listarCandidaturasDoProfissional(Long profissionalId);

    CandidaturaResponse atualizarStatus(Long candidaturaId, CandidaturaStatus status);
}
