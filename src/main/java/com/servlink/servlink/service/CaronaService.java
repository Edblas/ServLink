package com.servlink.servlink.service;

import com.servlink.servlink.dto.request.CaronaRequest;
import com.servlink.servlink.dto.response.CaronaResponse;
import java.util.List;

public interface CaronaService {
    CaronaResponse criar(CaronaRequest request);
    List<CaronaResponse> listar();
    CaronaResponse obter(Long id);
    void apagar(Long id);
    CaronaResponse atualizar(Long id, CaronaRequest request);
}
