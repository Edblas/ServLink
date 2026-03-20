package com.servlink.servlink.service;

import com.servlink.servlink.dto.request.LoginRequest;
import com.servlink.servlink.dto.request.RegisterRequest;
import com.servlink.servlink.dto.response.LoginResponse;

public interface AuthService {

    LoginResponse register(RegisterRequest request);

    LoginResponse login(LoginRequest request);
}
