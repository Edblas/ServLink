package com.servlink.servlink.service;

import com.servlink.servlink.dto.request.AssinaturaRequest;
import com.servlink.servlink.dto.response.AssinaturaResponse;

public interface AssinaturaService {

    AssinaturaResponse criar(AssinaturaRequest request);
}
