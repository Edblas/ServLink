package com.servlink.servlink.mapper;

import com.servlink.servlink.domain.entity.Profissional;
import com.servlink.servlink.dto.response.ProfissionalResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface ProfissionalMapper {

    @Mapping(target = "nome", source = "usuario.nome")
    @Mapping(target = "email", source = "usuario.email")
    @Mapping(target = "telefone", source = "usuario.telefone")
    @Mapping(target = "cidadeId", source = "cidade.id")
    @Mapping(target = "cidadeNome", source = "cidade.nome")
    @Mapping(target = "categoriaId", source = "categoria.id")
    @Mapping(target = "categoriaNome", source = "categoria.nome")
    ProfissionalResponse toResponse(Profissional profissional);
}
