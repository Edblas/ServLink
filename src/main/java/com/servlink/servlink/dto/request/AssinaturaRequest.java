package com.servlink.servlink.dto.request;

import com.servlink.servlink.domain.enums.Plano;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AssinaturaRequest {

    @NotNull
    private Long profissionalId;

    @NotNull
    private Plano plano;

    @NotNull
    private BigDecimal valor;

    @NotNull
    private LocalDate dataInicio;

    private LocalDate dataFim;
}
