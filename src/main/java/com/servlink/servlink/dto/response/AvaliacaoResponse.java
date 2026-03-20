package com.servlink.servlink.dto.response;

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
public class AvaliacaoResponse {

    private Long id;
    private Long clienteId;
    private Long profissionalId;
    private Integer nota;
    private String comentario;
    private LocalDateTime dataCriacao;
}
