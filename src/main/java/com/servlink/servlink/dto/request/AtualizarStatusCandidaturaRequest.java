package com.servlink.servlink.dto.request;

import com.servlink.servlink.domain.enums.CandidaturaStatus;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AtualizarStatusCandidaturaRequest {

    @NotNull
    private CandidaturaStatus status;
}

