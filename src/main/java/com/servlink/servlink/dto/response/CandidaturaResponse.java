package com.servlink.servlink.dto.response;

import com.servlink.servlink.domain.enums.CandidaturaStatus;
import java.math.BigDecimal;
import java.time.LocalDateTime;
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
public class CandidaturaResponse {

    private Long id;
    private Long vagaId;
    private String vagaTitulo;
    private Long profissionalId;
    private String profissionalNome;
    private BigDecimal profissionalMediaAvaliacoes;
    private String profissionalDescricao;
    private String profissionalCategoria;
    private CandidaturaStatus status;
    private LocalDateTime dataCandidatura;
}
