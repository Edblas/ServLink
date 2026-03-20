package com.servlink.servlink.domain.entity;

import com.servlink.servlink.domain.enums.AssinaturaStatus;
import com.servlink.servlink.domain.enums.Plano;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
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
@Table(name = "assinaturas")
public class Assinatura extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "profissional_id", nullable = false)
    @NotNull
    private Profissional profissional;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Plano plano;

    @Column(nullable = false)
    @NotNull
    private BigDecimal valor;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AssinaturaStatus status;

    @Column(nullable = false)
    private LocalDate dataInicio;

    private LocalDate dataFim;
}
