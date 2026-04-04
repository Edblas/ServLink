package com.servlink.servlink.service.impl;

import com.servlink.servlink.domain.entity.Usuario;
import com.servlink.servlink.domain.entity.Cliente;
import com.servlink.servlink.domain.entity.PasswordResetToken;
import com.servlink.servlink.domain.enums.Role;
import com.servlink.servlink.dto.request.ForgotPasswordRequest;
import com.servlink.servlink.dto.request.LoginRequest;
import com.servlink.servlink.dto.request.RegisterRequest;
import com.servlink.servlink.dto.request.ResetPasswordRequest;
import com.servlink.servlink.dto.response.AuthMeResponse;
import com.servlink.servlink.dto.response.LoginResponse;
import com.servlink.servlink.repository.ClienteRepository;
import com.servlink.servlink.repository.PasswordResetTokenRepository;
import com.servlink.servlink.repository.UsuarioRepository;
import com.servlink.servlink.service.AuthService;
import com.servlink.servlink.util.JwtTokenProvider;
import jakarta.transaction.Transactional;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Base64;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthServiceImpl implements AuthService {

    private final UsuarioRepository usuarioRepository;
    private final ClienteRepository clienteRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;
    private final JavaMailSender mailSender;

    public AuthServiceImpl(
            UsuarioRepository usuarioRepository,
            ClienteRepository clienteRepository,
            PasswordResetTokenRepository passwordResetTokenRepository,
            PasswordEncoder passwordEncoder,
            AuthenticationManager authenticationManager,
            JwtTokenProvider jwtTokenProvider,
            JavaMailSender mailSender) {
        this.usuarioRepository = usuarioRepository;
        this.clienteRepository = clienteRepository;
        this.passwordResetTokenRepository = passwordResetTokenRepository;
        this.passwordEncoder = passwordEncoder;
        this.authenticationManager = authenticationManager;
        this.jwtTokenProvider = jwtTokenProvider;
        this.mailSender = mailSender;
    }

    @Override
    @Transactional
    public LoginResponse register(RegisterRequest request) {
        String normalizedEmail = normalizeEmail(request.getEmail());
        if (usuarioRepository.existsByEmail(normalizedEmail)) {
            throw new IllegalArgumentException("Email já está em uso");
        }

        Role role = request.getRole() == null ? Role.PROFISSIONAL : request.getRole();
        if (role == Role.ADMIN) {
            throw new IllegalArgumentException("Role inválida");
        }

        Usuario usuario = new Usuario();
        usuario.setNome(request.getNome());
        usuario.setEmail(normalizedEmail);
        usuario.setTelefone(request.getTelefone());
        usuario.setSenha(passwordEncoder.encode(request.getSenha()));
        usuario.setRole(role);
        usuario.setAtivo(true);

        Usuario saved = usuarioRepository.save(usuario);

        if (role == Role.CLIENTE) {
            String cnpj = normalizeCnpj(request.getCnpj());
            if (cnpj.isEmpty()) {
                throw new IllegalArgumentException("Informe o CNPJ");
            }
            if (cnpj.length() != 14) {
                throw new IllegalArgumentException("CNPJ inválido");
            }
            String endereco = request.getEndereco() == null ? "" : request.getEndereco().trim();
            if (endereco.isEmpty()) {
                throw new IllegalArgumentException("Informe o endereço");
            }
            String cep = request.getCep() == null ? "" : request.getCep().replaceAll("[^0-9]", "").trim();
            if (cep.isEmpty() || cep.length() != 8) {
                throw new IllegalArgumentException("CEP inválido");
            }
            String numero = request.getNumero() == null ? "" : request.getNumero().trim();
            if (numero.isEmpty()) {
                throw new IllegalArgumentException("Informe o número");
            }
            if (clienteRepository.existsByCnpj(cnpj)) {
                throw new IllegalArgumentException("CNPJ já está em uso");
            }

            Cliente cliente = new Cliente();
            cliente.setUsuario(saved);
            cliente.setCnpj(cnpj);
            cliente.setEndereco(endereco);
            if (request.getCep() != null) {
                cliente.setCep(cep);
            }
            if (request.getNumero() != null) {
                cliente.setNumero(numero);
            }
            if (request.getComplemento() != null) {
                String complemento = request.getComplemento().trim();
                cliente.setComplemento(complemento.isEmpty() ? null : complemento);
            }
            cliente.setAtivo(true);
            clienteRepository.save(cliente);
        }

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

        String token = jwtTokenProvider.generateToken(usuario);

        return LoginResponse.builder()
                .accessToken(token)
                .tokenType("Bearer")
                .nome(usuario.getNome())
                .email(usuario.getEmail())
                .role(usuario.getRole())
                .build();
    }

    @Override
    @Transactional
    public void forgotPassword(ForgotPasswordRequest request) {
        String normalizedEmail = normalizeEmail(request.getEmail());
        Usuario usuario = usuarioRepository.findByEmail(normalizedEmail).orElse(null);
        if (usuario == null) {
            return;
        }

        String token = generateResetToken();
        String tokenHash = sha256Hex(token);

        PasswordResetToken entity = new PasswordResetToken();
        entity.setUsuario(usuario);
        entity.setTokenHash(tokenHash);
        entity.setExpiraEm(LocalDateTime.now().plusMinutes(30));
        entity.setAtivo(true);
        passwordResetTokenRepository.save(entity);

        sendResetTokenEmail(usuario.getEmail(), token);
    }

    @Override
    @Transactional
    public void resetPassword(ResetPasswordRequest request) {
        String token = request.getToken() == null ? "" : request.getToken().trim();
        if (token.isEmpty()) {
            throw new IllegalArgumentException("Token inválido");
        }

        String tokenHash = sha256Hex(token);
        PasswordResetToken resetToken = passwordResetTokenRepository.findByTokenHash(tokenHash)
                .orElseThrow(() -> new IllegalArgumentException("Token inválido"));

        if (resetToken.getUsadoEm() != null) {
            throw new IllegalArgumentException("Token inválido");
        }
        if (resetToken.getExpiraEm() == null || resetToken.getExpiraEm().isBefore(LocalDateTime.now())) {
            throw new IllegalArgumentException("Token expirado");
        }

        Usuario usuario = resetToken.getUsuario();
        usuario.setSenha(passwordEncoder.encode(request.getNovaSenha()));
        usuarioRepository.save(usuario);

        resetToken.setUsadoEm(LocalDateTime.now());
        passwordResetTokenRepository.save(resetToken);
    }

    @Override
    public AuthMeResponse me() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new IllegalStateException("Usuário não autenticado");
        }
        String email = authentication.getName();
        Usuario usuario = usuarioRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalStateException("Usuário não autenticado"));
        return new AuthMeResponse(usuario.getNome(), usuario.getEmail(), usuario.getRole());
    }

    private String normalizeEmail(String email) {
        if (email == null) return "";
        return email.trim().toLowerCase();
    }

    private String normalizeCnpj(String cnpj) {
        if (cnpj == null) return "";
        return cnpj.replaceAll("[^0-9]", "").trim();
    }

    private String generateResetToken() {
        byte[] bytes = new byte[32];
        new SecureRandom().nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private String sha256Hex(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashed = digest.digest(value.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(hashed.length * 2);
            for (byte b : hashed) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception ex) {
            throw new IllegalStateException("Falha ao processar token");
        }
    }

    private void sendResetTokenEmail(String to, String token) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(to);
            message.setSubject("ServLink - Recuperação de senha");
            message.setText("Use este código para redefinir sua senha: " + token);
            mailSender.send(message);
        } catch (Exception ex) {
        }
    }
}
