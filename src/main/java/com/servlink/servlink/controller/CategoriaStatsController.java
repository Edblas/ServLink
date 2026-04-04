package com.servlink.servlink.controller;

import com.servlink.servlink.dto.response.CategoriaCountResponse;
import com.servlink.servlink.repository.ProfissionalRepository;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class CategoriaStatsController {

    private final ProfissionalRepository profissionalRepository;

    public CategoriaStatsController(ProfissionalRepository profissionalRepository) {
        this.profissionalRepository = profissionalRepository;
    }

    @GetMapping("/api/categorias/counts")
    public ResponseEntity<List<CategoriaCountResponse>> counts(
            @RequestParam(required = false) Long cidadeId) {
        return ResponseEntity.ok(profissionalRepository.countByCategoria(cidadeId));
    }
}

