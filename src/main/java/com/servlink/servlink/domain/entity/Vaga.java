package com.servlink.servlink.domain.entity;

import com.servlink.servlink.domain.enums.VagaStatus;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "vagas")
public class Vaga extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "empresa_id", nullable = false)
    @NotNull
    private Cliente empresa;

    @NotBlank
    @Column(nullable = false)
    private String titulo;

    @NotBlank
    @Column(nullable = false, length = 2000)
    private String descricao;

    @NotNull
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal valor;

    @ManyToOne
    @JoinColumn(name = "cidade_id", nullable = false)
    @NotNull
    private Cidade cidade;

    @NotNull
    @Column(name = "data_trabalho", nullable = false)
    private LocalDate dataTrabalho;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private VagaStatus status;

    @ManyToOne
    @JoinColumn(name = "categoria_id", nullable = false)
    @NotNull
    private Categoria categoria;
}

