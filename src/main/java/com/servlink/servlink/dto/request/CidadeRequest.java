package com.servlink.servlink.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CidadeRequest {

    @NotBlank
    private String nome;

    @NotBlank
    private String estado;
}
