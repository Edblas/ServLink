package com.servlink.servlink.domain.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "clientes")
public class Cliente extends BaseEntity {

    @OneToOne
    @JoinColumn(name = "usuario_id", nullable = false, unique = true)
    @NotNull
    private Usuario usuario;
}
