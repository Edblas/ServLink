package com.servlink.servlink.dto.request;

import jakarta.validation.constraints.Min;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ProfissionalPerfilRequest {

    private String descricao;

    private String fotoUrl;

    @Min(0)
    private Integer anosExperiencia;

    private String bairro;

    private Long cidadeId;

    private Long categoriaId;
}
