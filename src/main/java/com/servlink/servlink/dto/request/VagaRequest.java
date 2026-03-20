package com.servlink.servlink.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class VagaRequest {

    @NotBlank
    private String titulo;

    @NotBlank
    private String descricao;

    @NotNull
    private BigDecimal valor;

    @NotNull
    private Long cidadeId;

    @NotNull
    private LocalDate dataTrabalho;

    @NotNull
    private Long categoriaId;
}

