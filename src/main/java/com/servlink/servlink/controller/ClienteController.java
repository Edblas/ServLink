package com.servlink.servlink.controller;

import com.servlink.servlink.dto.response.ClienteResponse;
import com.servlink.servlink.service.ClienteService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/clientes")
public class ClienteController {

    private final ClienteService clienteService;

    public ClienteController(ClienteService clienteService) {
        this.clienteService = clienteService;
    }

    @PostMapping("/me")
    public ResponseEntity<ClienteResponse> criarOuObter() {
        ClienteResponse response = clienteService.criarOuObterClienteAtual();
        return ResponseEntity.ok(response);
    }

    @GetMapping("/me")
    public ResponseEntity<ClienteResponse> obter() {
        ClienteResponse response = clienteService.obterClienteAtual();
        return ResponseEntity.ok(response);
    }
}

