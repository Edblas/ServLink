package com.servlink.servlink.controller;

import com.servlink.servlink.dto.request.ProfissionalRequest;
import com.servlink.servlink.dto.request.ProfissionalPerfilRequest;
import com.servlink.servlink.dto.response.AvaliacaoResponse;
import com.servlink.servlink.dto.response.ProfissionalResponse;
import com.servlink.servlink.service.AvaliacaoService;
import com.servlink.servlink.service.ProfissionalService;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ProfissionalController {

    private final ProfissionalService profissionalService;
    private final AvaliacaoService avaliacaoService;

    public ProfissionalController(ProfissionalService profissionalService, AvaliacaoService avaliacaoService) {
        this.profissionalService = profissionalService;
        this.avaliacaoService = avaliacaoService;
    }

    @PostMapping("/api/admin/profissionais")
    public ResponseEntity<ProfissionalResponse> criar(@Valid @RequestBody ProfissionalRequest request) {
        ProfissionalResponse response = profissionalService.criar(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/api/profissionais")
    public ResponseEntity<Page<ProfissionalResponse>> buscar(
            @RequestParam(required = false) Long cidadeId,
            @RequestParam(required = false) Long categoriaId,
            @RequestParam(required = false) String q,
            @RequestParam(required = false) String bairro,
            @RequestParam(defaultValue = "0") int pagina,
            @RequestParam(defaultValue = "20") int tamanho) {

        Page<ProfissionalResponse> page = profissionalService.buscar(cidadeId, categoriaId, q, bairro, pagina, tamanho);
        return ResponseEntity.ok(page);
    }

    @PostMapping("/api/profissionais/me")
    public ResponseEntity<ProfissionalResponse> criarOuObter() {
        ProfissionalResponse response = profissionalService.criarOuObterProfissionalAtual();
        return ResponseEntity.ok(response);
    }

    @GetMapping("/api/profissionais/me")
    public ResponseEntity<ProfissionalResponse> obter() {
        ProfissionalResponse response = profissionalService.obterProfissionalAtual();
        return ResponseEntity.ok(response);
    }

    @PatchMapping("/api/profissionais/me")
    public ResponseEntity<ProfissionalResponse> atualizar(@Valid @RequestBody ProfissionalPerfilRequest request) {
        ProfissionalResponse response = profissionalService.atualizarProfissionalAtual(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/api/profissionais/{profissionalId}/avaliacoes")
    public ResponseEntity<List<AvaliacaoResponse>> listarAvaliacoes(@PathVariable Long profissionalId) {
        List<AvaliacaoResponse> avaliacoes = avaliacaoService.listarPorProfissional(profissionalId);
        return ResponseEntity.ok(avaliacoes);
    }
}
