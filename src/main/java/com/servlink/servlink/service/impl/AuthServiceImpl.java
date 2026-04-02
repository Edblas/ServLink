package com.servlink.servlink.service.impl;

import com.servlink.servlink.domain.entity.Usuario;
import com.servlink.servlink.domain.entity.Cliente;
import com.servlink.servlink.domain.enums.Role;
import com.servlink.servlink.dto.request.LoginRequest;
import com.servlink.servlink.dto.request.RegisterRequest;
import com.servlink.servlink.dto.response.LoginResponse;
import com.servlink.servlink.repository.ClienteRepository;
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
    private final ClienteRepository clienteRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;

    public AuthServiceImpl(
            UsuarioRepository usuarioRepository,
            ClienteRepository clienteRepository,
            PasswordEncoder passwordEncoder,
            AuthenticationManager authenticationManager,
            JwtTokenProvider jwtTokenProvider) {
        this.usuarioRepository = usuarioRepository;
        this.clienteRepository = clienteRepository;
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

    private String normalizeCnpj(String cnpj) {
        if (cnpj == null) return "";
        return cnpj.replaceAll("[^0-9]", "").trim();
    }
}
