package com.servlink.servlink.service;

import com.servlink.servlink.dto.request.ProfissionalRequest;
import com.servlink.servlink.dto.response.ProfissionalResponse;
import org.springframework.data.domain.Page;

public interface ProfissionalService {

    ProfissionalResponse criar(ProfissionalRequest request);

    Page<ProfissionalResponse> buscar(
            Long cidadeId,
            Long categoriaId,
            int pagina,
            int tamanho);
}
