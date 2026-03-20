package com.servlink.servlink.service;

import com.servlink.servlink.dto.response.ClienteResponse;

public interface ClienteService {

    ClienteResponse criarOuObterClienteAtual();

    ClienteResponse obterClienteAtual();
}

