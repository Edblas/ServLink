package com.servlink.servlink.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AvaliacaoPorProfissionalRequest {

    @NotNull
    @Min(1)
    @Max(5)
    private Integer nota;

    private String comentario;
}

