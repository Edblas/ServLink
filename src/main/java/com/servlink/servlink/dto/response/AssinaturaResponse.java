package com.servlink.servlink.dto.response;

import com.servlink.servlink.domain.enums.AssinaturaStatus;
import com.servlink.servlink.domain.enums.Plano;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AssinaturaResponse {

    private Long id;
    private Long profissionalId;
    private Plano plano;
    private BigDecimal valor;
    private AssinaturaStatus status;
    private LocalDate dataInicio;
    private LocalDate dataFim;
}
