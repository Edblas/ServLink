package com.servlink.servlink.controller;

import com.servlink.servlink.dto.response.CidadeResponse;
import com.servlink.servlink.service.CidadeService;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/cidades")
public class CidadePublicController {

    private final CidadeService cidadeService;

    public CidadePublicController(CidadeService cidadeService) {
        this.cidadeService = cidadeService;
    }

    @GetMapping
    public ResponseEntity<List<CidadeResponse>> listar() {
        List<CidadeResponse> cidades = cidadeService.listarTodas();
        return ResponseEntity.ok(cidades);
    }
}

