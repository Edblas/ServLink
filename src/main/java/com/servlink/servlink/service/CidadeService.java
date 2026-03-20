package com.servlink.servlink.service;

import com.servlink.servlink.dto.request.CidadeRequest;
import com.servlink.servlink.dto.response.CidadeResponse;
import java.util.List;

public interface CidadeService {

    CidadeResponse criar(CidadeRequest request);

    List<CidadeResponse> listarTodas();
}
