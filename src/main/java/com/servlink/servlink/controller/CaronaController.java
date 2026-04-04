package com.servlink.servlink.controller;

import com.servlink.servlink.dto.request.CaronaRequest;
import com.servlink.servlink.dto.response.CaronaResponse;
import com.servlink.servlink.service.CaronaService;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class CaronaController {

    private final CaronaService caronaService;

    public CaronaController(CaronaService caronaService) {
        this.caronaService = caronaService;
    }

    @PostMapping("/api/caronas")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<CaronaResponse> criar(@Valid @RequestBody CaronaRequest request) {
        CaronaResponse response = caronaService.criar(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/api/caronas")
    public ResponseEntity<List<CaronaResponse>> listar() {
        return ResponseEntity.ok(caronaService.listar());
    }

    @GetMapping("/api/caronas/{id}")
    public ResponseEntity<CaronaResponse> obter(@PathVariable Long id) {
        return ResponseEntity.ok(caronaService.obter(id));
    }

    @DeleteMapping("/api/caronas/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Void> apagar(@PathVariable Long id) {
        caronaService.apagar(id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/api/caronas/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<CaronaResponse> atualizar(
            @PathVariable Long id,
            @Valid @RequestBody CaronaRequest request) {
        return ResponseEntity.ok(caronaService.atualizar(id, request));
    }
}
