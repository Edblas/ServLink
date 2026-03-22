package com.servlink.servlink.dto.request;

import com.servlink.servlink.domain.enums.Plano;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ProfissionalRequest {

    @NotNull
    private Long usuarioId;

    @NotBlank
    private String descricao;

    private String fotoUrl;

    private String bairro;

    @NotNull
    private Plano plano;

    @NotNull
    private Long cidadeId;

    @NotNull
    private Long categoriaId;
}
