package com.servlink.servlink.service.impl;

import com.servlink.servlink.domain.entity.Cliente;
import com.servlink.servlink.domain.entity.Usuario;
import com.servlink.servlink.dto.response.ClienteResponse;
import com.servlink.servlink.repository.ClienteRepository;
import com.servlink.servlink.repository.UsuarioRepository;
import com.servlink.servlink.service.ClienteService;
import jakarta.transaction.Transactional;
import java.util.Optional;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Service
public class ClienteServiceImpl implements ClienteService {

    private final ClienteRepository clienteRepository;
    private final UsuarioRepository usuarioRepository;

    public ClienteServiceImpl(ClienteRepository clienteRepository, UsuarioRepository usuarioRepository) {
        this.clienteRepository = clienteRepository;
        this.usuarioRepository = usuarioRepository;
    }

    @Override
    @Transactional
    @PreAuthorize("hasAnyRole('CLIENTE','PROFISSIONAL')")
    public ClienteResponse criarOuObterClienteAtual() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new IllegalStateException("Usuário não autenticado");
        }

        String email = authentication.getName();

        Optional<Cliente> existente = clienteRepository.findByUsuarioEmail(email);
        if (existente.isPresent()) {
            return toResponse(existente.get());
        }

        Usuario usuario = usuarioRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));

        Cliente cliente = new Cliente();
        cliente.setUsuario(usuario);
        cliente.setAtivo(true);

        Cliente salvo = clienteRepository.save(cliente);
        return toResponse(salvo);
    }

    @Override
    @PreAuthorize("hasAnyRole('CLIENTE','PROFISSIONAL')")
    public ClienteResponse obterClienteAtual() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new IllegalStateException("Usuário não autenticado");
        }

        String email = authentication.getName();

        Cliente cliente = clienteRepository.findByUsuarioEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Cliente não encontrado"));

        return toResponse(cliente);
    }

    private ClienteResponse toResponse(Cliente cliente) {
        Usuario usuario = cliente.getUsuario();
        return ClienteResponse.builder()
                .id(cliente.getId())
                .usuarioId(usuario.getId())
                .nome(usuario.getNome())
                .email(usuario.getEmail())
                .ativo(cliente.getAtivo())
                .build();
    }
}
