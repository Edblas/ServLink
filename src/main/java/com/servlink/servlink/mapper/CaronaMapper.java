package com.servlink.servlink.mapper;

import com.servlink.servlink.domain.entity.Carona;
import com.servlink.servlink.dto.response.CaronaResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface CaronaMapper {
    @Mapping(target = "usuarioId", source = "usuario.id")
    @Mapping(target = "usuarioNome", source = "usuario.nome")
    @Mapping(
            target = "dataCriacao",
            expression = "java(carona.getDataCriacao() == null ? null : java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME.format(carona.getDataCriacao()))")
    CaronaResponse toResponse(Carona carona);
}
