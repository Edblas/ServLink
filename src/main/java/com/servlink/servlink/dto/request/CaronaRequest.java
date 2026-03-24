package com.servlink.servlink.dto.request;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CaronaRequest {
    @NotBlank
    private String origem;
    @NotBlank
    private String destino;
    @NotNull
    private LocalDateTime dataHora;
    @NotNull
    @Min(1)
    private Integer vagas;
    private BigDecimal valor;
    @NotBlank
    private String telefone;
    private String observacao;
}
