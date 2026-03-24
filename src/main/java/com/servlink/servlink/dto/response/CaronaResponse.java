package com.servlink.servlink.dto.response;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CaronaResponse {
    private Long id;
    private Long usuarioId;
    private String usuarioNome;
    private String origem;
    private String destino;
    private LocalDateTime dataHora;
    private Integer vagas;
    private BigDecimal valor;
    private String telefone;
    private String observacao;
    private Boolean ativo;
    private String dataCriacao;
}
