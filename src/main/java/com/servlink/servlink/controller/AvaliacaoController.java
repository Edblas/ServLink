package com.servlink.servlink.controller;

import com.servlink.servlink.dto.request.AvaliacaoRequest;
import com.servlink.servlink.dto.response.AvaliacaoResponse;
import com.servlink.servlink.service.AvaliacaoService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/avaliacoes")
public class AvaliacaoController {

    private final AvaliacaoService avaliacaoService;

    public AvaliacaoController(AvaliacaoService avaliacaoService) {
        this.avaliacaoService = avaliacaoService;
    }

    @PostMapping
    public ResponseEntity<AvaliacaoResponse> criar(@Valid @RequestBody AvaliacaoRequest request) {
        AvaliacaoResponse response = avaliacaoService.criar(request);
        return ResponseEntity.ok(response);
    }
}
