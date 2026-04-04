package com.servlink.servlink.controller;

import com.servlink.servlink.dto.request.VagaRequest;
import com.servlink.servlink.dto.response.VagaResponse;
import com.servlink.servlink.service.VagaService;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class VagaController {

    private final VagaService vagaService;

    public VagaController(VagaService vagaService) {
        this.vagaService = vagaService;
    }

    @PostMapping("/api/vagas")
    @PreAuthorize("hasAnyRole('CLIENTE','PROFISSIONAL')")
    public ResponseEntity<VagaResponse> criar(@Valid @RequestBody VagaRequest request) {
        VagaResponse response = vagaService.criar(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/api/vagas")
    public ResponseEntity<List<VagaResponse>> listar() {
        return ResponseEntity.ok(vagaService.listar());
    }

    @GetMapping("/api/vagas/{id}")
    public ResponseEntity<VagaResponse> obter(@PathVariable Long id) {
        return ResponseEntity.ok(vagaService.obter(id));
    }

    @GetMapping("/api/empresas/{empresaId}/vagas")
    @PreAuthorize("hasAnyRole('CLIENTE','PROFISSIONAL')")
    public ResponseEntity<List<VagaResponse>> listarPorEmpresa(@PathVariable Long empresaId) {
        return ResponseEntity.ok(vagaService.listarPorEmpresa(empresaId));
    }

    @DeleteMapping("/api/vagas/{id}")
    @PreAuthorize("hasAnyRole('CLIENTE','PROFISSIONAL')")
    public ResponseEntity<Void> apagar(@PathVariable Long id) {
        vagaService.apagar(id);
        return ResponseEntity.noContent().build();
    }
}
