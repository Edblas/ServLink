package com.servlink.servlink.controller;

import com.servlink.servlink.dto.request.CidadeRequest;
import com.servlink.servlink.dto.response.CidadeResponse;
import com.servlink.servlink.service.CidadeService;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/cidades")
public class CidadeController {

    private final CidadeService cidadeService;

    public CidadeController(CidadeService cidadeService) {
        this.cidadeService = cidadeService;
    }

    @PostMapping
    public ResponseEntity<CidadeResponse> criar(@Valid @RequestBody CidadeRequest request) {
        CidadeResponse response = cidadeService.criar(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    public ResponseEntity<List<CidadeResponse>> listar() {
        List<CidadeResponse> cidades = cidadeService.listarTodas();
        return ResponseEntity.ok(cidades);
    }
}
