package com.servlink.servlink.mapper;

import com.servlink.servlink.domain.entity.Assinatura;
import com.servlink.servlink.dto.response.AssinaturaResponse;
import org.springframework.stereotype.Component;

@Component
public class AssinaturaMapper {

    public AssinaturaResponse toResponse(Assinatura assinatura) {
        if (assinatura == null) {
            return null;
        }
        Long profissionalId = null;
        if (assinatura.getProfissional() != null) {
            profissionalId = assinatura.getProfissional().getId();
        }
        return AssinaturaResponse.builder()
                .id(assinatura.getId())
                .profissionalId(profissionalId)
                .plano(assinatura.getPlano())
                .valor(assinatura.getValor())
                .status(assinatura.getStatus())
                .dataInicio(assinatura.getDataInicio())
                .dataFim(assinatura.getDataFim())
                .build();
    }
}
