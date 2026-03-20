package com.servlink.servlink.mapper;

import com.servlink.servlink.domain.entity.Cidade;
import com.servlink.servlink.dto.request.CidadeRequest;
import com.servlink.servlink.dto.response.CidadeResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface CidadeMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "ativo", ignore = true)
    @Mapping(target = "dataCriacao", ignore = true)
    @Mapping(target = "dataAtualizacao", ignore = true)
    Cidade toEntity(CidadeRequest request);

    CidadeResponse toResponse(Cidade cidade);
}
