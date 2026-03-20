package com.servlink.servlink.mapper;

import com.servlink.servlink.domain.entity.Candidatura;
import com.servlink.servlink.dto.response.CandidaturaResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface CandidaturaMapper {

    @Mapping(target = "vagaId", source = "vaga.id")
    @Mapping(target = "vagaTitulo", source = "vaga.titulo")
    @Mapping(target = "profissionalId", source = "profissional.id")
    @Mapping(target = "profissionalNome", source = "profissional.usuario.nome")
    @Mapping(target = "profissionalMediaAvaliacoes", source = "profissional.mediaAvaliacoes")
    @Mapping(target = "profissionalDescricao", source = "profissional.descricao")
    @Mapping(target = "profissionalCategoria", source = "profissional.categoria.nome")
    CandidaturaResponse toResponse(Candidatura candidatura);
}
