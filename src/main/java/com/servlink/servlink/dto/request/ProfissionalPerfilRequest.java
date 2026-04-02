package com.servlink.servlink.dto.request;

import com.servlink.servlink.domain.enums.TipoPagamento;
import jakarta.validation.constraints.Min;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ProfissionalPerfilRequest {

    private String nome;

    private String telefone;

    private String descricao;

    private String fotoUrl;

    @Min(0)
    private Integer anosExperiencia;

    @Min(0)
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

    private Long cidadeId;

    private Long categoriaId;
}
