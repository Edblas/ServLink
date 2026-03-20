package com.servlink.servlink.domain.entity;

import com.servlink.servlink.domain.enums.CandidaturaStatus;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(
        name = "candidaturas",
        uniqueConstraints = @UniqueConstraint(name = "uq_vaga_profissional", columnNames = {"vaga_id", "profissional_id"})
)
public class Candidatura extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "vaga_id", nullable = false)
    @NotNull
    private Vaga vaga;

    @ManyToOne
    @JoinColumn(name = "profissional_id", nullable = false)
    @NotNull
    private Profissional profissional;

    @NotNull
    @Column(name = "data_candidatura", nullable = false)
    private LocalDateTime dataCandidatura;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CandidaturaStatus status;
}

