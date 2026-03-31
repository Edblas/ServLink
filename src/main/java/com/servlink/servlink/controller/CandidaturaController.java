package com.servlink.servlink.controller;

import com.servlink.servlink.dto.request.AtualizarStatusCandidaturaRequest;
import com.servlink.servlink.dto.response.CandidaturaResponse;
import com.servlink.servlink.service.CandidaturaService;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class CandidaturaController {

    private final CandidaturaService candidaturaService;

    public CandidaturaController(CandidaturaService candidaturaService) {
        this.candidaturaService = candidaturaService;
    }

    @PostMapping("/api/vagas/{vagaId}/candidatar")
    @PreAuthorize("hasRole('PROFISSIONAL')")
    public ResponseEntity<CandidaturaResponse> candidatar(@PathVariable Long vagaId) {
        return ResponseEntity.ok(candidaturaService.candidatar(vagaId));
    }

    @GetMapping("/api/vagas/{vagaId}/candidatos")
    @PreAuthorize("hasAnyRole('CLIENTE','PROFISSIONAL')")
    public ResponseEntity<List<CandidaturaResponse>> listarCandidatos(@PathVariable Long vagaId) {
        return ResponseEntity.ok(candidaturaService.listarCandidatosDaVaga(vagaId));
    }

    @GetMapping("/api/profissionais/{id}/candidaturas")
    @PreAuthorize("hasRole('PROFISSIONAL')")
    public ResponseEntity<List<CandidaturaResponse>> listarCandidaturas(@PathVariable Long id) {
        return ResponseEntity.ok(candidaturaService.listarCandidaturasDoProfissional(id));
    }

    @PatchMapping("/api/candidaturas/{id}/status")
    @PreAuthorize("hasAnyRole('CLIENTE','PROFISSIONAL')")
    public ResponseEntity<CandidaturaResponse> atualizarStatus(
            @PathVariable Long id, @Valid @RequestBody AtualizarStatusCandidaturaRequest request) {
        return ResponseEntity.ok(candidaturaService.atualizarStatus(id, request.getStatus()));
    }
}
