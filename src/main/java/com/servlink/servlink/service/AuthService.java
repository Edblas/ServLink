package com.servlink.servlink.service;

import com.servlink.servlink.dto.request.LoginRequest;
import com.servlink.servlink.dto.request.RegisterRequest;
import com.servlink.servlink.dto.request.ForgotPasswordRequest;
import com.servlink.servlink.dto.request.ResetPasswordRequest;
import com.servlink.servlink.dto.response.AuthMeResponse;
import com.servlink.servlink.dto.response.LoginResponse;

public interface AuthService {

    LoginResponse register(RegisterRequest request);

    LoginResponse login(LoginRequest request);

    void forgotPassword(ForgotPasswordRequest request);

    void resetPassword(ResetPasswordRequest request);

    AuthMeResponse me();
}
