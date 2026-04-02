package com.servlink.servlink.dto.response;

import com.servlink.servlink.domain.enums.Plano;
import com.servlink.servlink.domain.enums.TipoPagamento;
import java.math.BigDecimal;
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
public class ProfissionalResponse {

    private Long id;
    private String nome;
    private String email;
    private String telefone;
    private String descricao;
    private String fotoUrl;
    private Integer anosExperiencia;
    private Integer idade;
    private TipoPagamento tipoPagamento;
    private String instagramUrl;
    private String tiktokUrl;
    private String siteUrl;
    private String endereco;
    private String cep;
    private String numero;
    private String complemento;
    private String bairro;
    private Boolean carteiraMotorista;
    private Plano plano;
    private Long cidadeId;
    private String cidadeNome;
    private Long categoriaId;
    private String categoriaNome;
    private BigDecimal mediaAvaliacoes;
}
