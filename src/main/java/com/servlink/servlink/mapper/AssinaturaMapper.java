package com.servlink.servlink.mapper;

import com.servlink.servlink.domain.entity.Assinatura;
import com.servlink.servlink.dto.response.AssinaturaResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface AssinaturaMapper {

    @Mapping(target = "profissionalId", source = "profissional.id")
    AssinaturaResponse toResponse(Assinatura assinatura);
}
