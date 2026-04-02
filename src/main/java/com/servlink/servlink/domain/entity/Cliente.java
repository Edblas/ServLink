package com.servlink.servlink.domain.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import jakarta.persistence.Column;
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

    @Column(length = 14)
    private String cnpj;

    @Column(length = 255)
    private String endereco;

    @Column(length = 8)
    private String cep;

    @Column(length = 20)
    private String numero;

    @Column(length = 120)
    private String complemento;
}
