package com.servlink.servlink.service.impl;

import com.servlink.servlink.domain.entity.Usuario;
import com.servlink.servlink.dto.request.LoginRequest;
import com.servlink.servlink.dto.request.RegisterRequest;
import com.servlink.servlink.dto.response.LoginResponse;
import com.servlink.servlink.repository.UsuarioRepository;
import com.servlink.servlink.service.AuthService;
import com.servlink.servlink.util.JwtTokenProvider;
import jakarta.transaction.Transactional;
import java.util.List;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthServiceImpl implements AuthService {

    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;

    public AuthServiceImpl(
            UsuarioRepository usuarioRepository,
            PasswordEncoder passwordEncoder,
            AuthenticationManager authenticationManager,
            JwtTokenProvider jwtTokenProvider) {
        this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = passwordEncoder;
        this.authenticationManager = authenticationManager;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    @Override
    @Transactional
    public LoginResponse register(RegisterRequest request) {
        String normalizedEmail = normalizeEmail(request.getEmail());
        List<Usuario> existing = usuarioRepository.findAllByEmailNormalized(normalizedEmail);
        if (!existing.isEmpty()) {
            throw new IllegalArgumentException("Email já está em uso");
        }

        Usuario usuario = new Usuario();
        usuario.setNome(request.getNome());
        usuario.setEmail(normalizedEmail);
        usuario.setTelefone(request.getTelefone());
        usuario.setSenha(passwordEncoder.encode(request.getSenha()));
        usuario.setRole(request.getRole());
        usuario.setAtivo(true);

        Usuario saved = usuarioRepository.save(usuario);

        String token = jwtTokenProvider.generateToken(saved);

        return LoginResponse.builder()
                .accessToken(token)
                .tokenType("Bearer")
                .nome(saved.getNome())
                .email(saved.getEmail())
                .role(saved.getRole())
                .build();
    }

    @Override
    public LoginResponse login(LoginRequest request) {
        String normalizedEmail = normalizeEmail(request.getEmail());
        Authentication authentication = new UsernamePasswordAuthenticationToken(
                normalizedEmail,
                request.getSenha());

        Authentication authenticated = authenticationManager.authenticate(authentication);

        Usuario usuario = (Usuario) authenticated.getPrincipal();
        if (!normalizedEmail.equals(usuario.getEmail())) {
            List<Usuario> existing = usuarioRepository.findAllByEmailNormalized(normalizedEmail);
            boolean canUpdate = existing.isEmpty() || existing.get(0).getId().equals(usuario.getId());
            if (canUpdate) {
                usuario.setEmail(normalizedEmail);
                usuario = usuarioRepository.save(usuario);
            }
        }
        String token = jwtTokenProvider.generateToken(usuario);

        return LoginResponse.builder()
                .accessToken(token)
                .tokenType("Bearer")
                .nome(usuario.getNome())
                .email(usuario.getEmail())
                .role(usuario.getRole())
                .build();
    }

    private String normalizeEmail(String email) {
        if (email == null) return "";
        return email.trim().toLowerCase();
    }
}
