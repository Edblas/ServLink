package com.servlink.servlink.mapper;

import com.servlink.servlink.domain.entity.Categoria;
import com.servlink.servlink.dto.request.CategoriaRequest;
import com.servlink.servlink.dto.response.CategoriaResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface CategoriaMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "ativo", ignore = true)
    @Mapping(target = "dataCriacao", ignore = true)
    @Mapping(target = "dataAtualizacao", ignore = true)
    Categoria toEntity(CategoriaRequest request);

    CategoriaResponse toResponse(Categoria categoria);
}
