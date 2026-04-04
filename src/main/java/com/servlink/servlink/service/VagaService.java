package com.servlink.servlink.service;

import com.servlink.servlink.dto.request.VagaRequest;
import com.servlink.servlink.dto.response.VagaResponse;
import java.util.List;

public interface VagaService {

    VagaResponse criar(VagaRequest request);

    List<VagaResponse> listar();

    VagaResponse obter(Long id);

    List<VagaResponse> listarPorEmpresa(Long empresaId);

    void apagar(Long id);

    VagaResponse atualizar(Long id, VagaRequest request);
}
