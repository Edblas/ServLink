package com.servlink.servlink.mapper;

import com.servlink.servlink.domain.entity.Avaliacao;
import com.servlink.servlink.dto.response.AvaliacaoResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface AvaliacaoMapper {

    @Mapping(target = "clienteId", source = "cliente.id")
    @Mapping(target = "profissionalId", source = "profissional.id")
    @Mapping(target = "dataCriacao", source = "dataCriacao")
    AvaliacaoResponse toResponse(Avaliacao avaliacao);
}
