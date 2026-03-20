package com.servlink.servlink.mapper;

import com.servlink.servlink.domain.entity.Vaga;
import com.servlink.servlink.dto.response.VagaResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface VagaMapper {

    @Mapping(target = "empresaId", source = "empresa.id")
    @Mapping(target = "empresaNome", source = "empresa.usuario.nome")
    @Mapping(target = "cidadeId", source = "cidade.id")
    @Mapping(target = "cidadeNome", source = "cidade.nome")
    @Mapping(target = "categoriaId", source = "categoria.id")
    @Mapping(target = "categoriaNome", source = "categoria.nome")
    @Mapping(target = "createdAt", source = "dataCriacao")
    VagaResponse toResponse(Vaga vaga);
}

