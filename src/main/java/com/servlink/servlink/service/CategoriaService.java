package com.servlink.servlink.service;

import com.servlink.servlink.dto.request.CategoriaRequest;
import com.servlink.servlink.dto.response.CategoriaResponse;
import java.util.List;

public interface CategoriaService {

    CategoriaResponse criar(CategoriaRequest request);

    List<CategoriaResponse> listarTodas();
}
