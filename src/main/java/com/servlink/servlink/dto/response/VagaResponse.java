package com.servlink.servlink.dto.response;

import com.servlink.servlink.domain.enums.VagaStatus;
import com.servlink.servlink.domain.enums.VagaTipo;
import com.servlink.servlink.domain.enums.VagaUrgencia;
import java.math.BigDecimal;
import java.time.LocalDate;
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
public class VagaResponse {

    private Long id;
    private Long empresaId;
    private String empresaNome;
    private String empresaTelefone;
    private String empresaEmail;
    private String titulo;
    private String descricao;
    private BigDecimal valor;
    private Long cidadeId;
    private String cidadeNome;
    private LocalDate dataTrabalho;
    private VagaUrgencia urgencia;
    private VagaTipo tipo;
    private VagaStatus status;
    private Long categoriaId;
    private String categoriaNome;
    private LocalDateTime createdAt;
    private LocalDateTime expiraEm;
    private Long candidaturasCount;
}
