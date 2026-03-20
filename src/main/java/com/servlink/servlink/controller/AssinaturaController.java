package com.servlink.servlink.controller;

import com.servlink.servlink.dto.request.AssinaturaRequest;
import com.servlink.servlink.dto.response.AssinaturaResponse;
import com.servlink.servlink.service.AssinaturaService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/assinaturas")
public class AssinaturaController {

    private final AssinaturaService assinaturaService;

    public AssinaturaController(AssinaturaService assinaturaService) {
        this.assinaturaService = assinaturaService;
    }

    @PostMapping
    public ResponseEntity<AssinaturaResponse> criar(@Valid @RequestBody AssinaturaRequest request) {
        AssinaturaResponse response = assinaturaService.criar(request);
        return ResponseEntity.ok(response);
    }
}
