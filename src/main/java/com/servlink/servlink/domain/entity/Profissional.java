package com.servlink.servlink.domain.entity;

import com.servlink.servlink.domain.enums.Plano;
import com.servlink.servlink.domain.enums.TipoPagamento;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "profissionais")
public class Profissional extends BaseEntity {

    @OneToOne
    @JoinColumn(name = "usuario_id", nullable = false, unique = true)
    @NotNull
    private Usuario usuario;

    @NotBlank
    @Column(nullable = false)
    private String descricao;

    private String fotoUrl;

    private Integer anosExperiencia;

    private Integer idade;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private TipoPagamento tipoPagamento;

    @Column(name = "instagram_url", length = 255)
    private String instagramUrl;

    @Column(name = "tiktok_url", length = 255)
    private String tiktokUrl;

    @Column(name = "site_url", length = 255)
    private String siteUrl;

    @Column(length = 255)
    private String endereco;

    @Column(length = 8)
    private String cep;

    @Column(length = 20)
    private String numero;

    @Column(length = 120)
    private String complemento;

    @Column(length = 255)
    private String bairro;

    @Column(name = "carteira_motorista")
    private Boolean carteiraMotorista;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Plano plano;

    @ManyToOne
    @JoinColumn(name = "cidade_id")
    private Cidade cidade;

    @ManyToOne
    @JoinColumn(name = "categoria_id")
    private Categoria categoria;

    @Column(precision = 3, scale = 2)
    private BigDecimal mediaAvaliacoes;
}
