package com.servlink.servlink.dto.response;

import com.servlink.servlink.domain.enums.Role;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class AuthMeResponse {

    private String nome;
    private String email;
    private Role role;
}

