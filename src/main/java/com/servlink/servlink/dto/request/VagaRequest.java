package com.servlink.servlink.dto.request;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.servlink.servlink.domain.enums.VagaTipo;
import com.servlink.servlink.domain.enums.VagaUrgencia;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class VagaRequest {

    @NotBlank
    private String titulo;

    @NotBlank
    private String descricao;

    @NotNull
    @JsonAlias({"valor_estimado"})
    private BigDecimal valor;

    @NotNull
    private Long cidadeId;

    @NotNull
    private LocalDate dataTrabalho;

    @NotNull
    private VagaUrgencia urgencia;

    private VagaTipo tipo;

    @NotNull
    private Long categoriaId;
}
