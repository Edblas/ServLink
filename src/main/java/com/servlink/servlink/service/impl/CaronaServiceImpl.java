package com.servlink.servlink.service.impl;

import com.servlink.servlink.domain.entity.Carona;
import com.servlink.servlink.domain.entity.Usuario;
import com.servlink.servlink.dto.request.CaronaRequest;
import com.servlink.servlink.dto.response.CaronaResponse;
import com.servlink.servlink.mapper.CaronaMapper;
import com.servlink.servlink.repository.CaronaRepository;
import com.servlink.servlink.repository.UsuarioRepository;
import com.servlink.servlink.service.CaronaService;
import jakarta.transaction.Transactional;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

@Service
public class CaronaServiceImpl implements CaronaService {

    private final CaronaRepository caronaRepository;
    private final UsuarioRepository usuarioRepository;
    private final CaronaMapper caronaMapper;

    public CaronaServiceImpl(CaronaRepository caronaRepository, UsuarioRepository usuarioRepository, CaronaMapper caronaMapper) {
        this.caronaRepository = caronaRepository;
        this.usuarioRepository = usuarioRepository;
        this.caronaMapper = caronaMapper;
    }

    @Override
    @Transactional
    public CaronaResponse criar(CaronaRequest request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new IllegalStateException("Usuário não autenticado");
        }
        Object principal = authentication.getPrincipal();
        String email = principal instanceof UserDetails ud ? ud.getUsername() : authentication.getName();
        Usuario usuario = usuarioRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));

        Carona carona = new Carona();
        carona.setUsuario(usuario);
        carona.setOrigem(request.getOrigem());
        carona.setDestino(request.getDestino());
        carona.setDataHora(request.getDataHora());
        carona.setVagas(request.getVagas());
        carona.setValor(request.getValor());
        carona.setTelefone(request.getTelefone());
        carona.setObservacao(request.getObservacao());
        carona.setAtivo(true);

        Carona salva = caronaRepository.save(carona);
        return caronaMapper.toResponse(salva);
    }

    @Override
    public List<CaronaResponse> listar() {
        return caronaRepository.findAllByAtivoTrueOrderByDataCriacaoDesc().stream()
                .map(caronaMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public CaronaResponse obter(Long id) {
        Carona carona = caronaRepository.findByIdAtivaWithUsuario(id)
                .orElseThrow(() -> new IllegalArgumentException("Carona não encontrada"));
        return caronaMapper.toResponse(carona);
    }

    @Override
    @Transactional
    public void apagar(Long id) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new IllegalStateException("Usuário não autenticado");
        }
        Object principal = authentication.getPrincipal();
        String email = principal instanceof UserDetails ud ? ud.getUsername() : authentication.getName();
        Usuario usuario = usuarioRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));

        Carona carona = caronaRepository.findByIdAtivaWithUsuario(id)
                .orElseThrow(() -> new IllegalArgumentException("Carona não encontrada"));

        if (carona.getUsuario() == null || carona.getUsuario().getId() == null
                || !carona.getUsuario().getId().equals(usuario.getId())) {
            throw new AccessDeniedException("Acesso negado");
        }

        carona.setAtivo(false);
        caronaRepository.save(carona);
    }

    @Override
    @Transactional
    public CaronaResponse atualizar(Long id, CaronaRequest request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new IllegalStateException("Usuário não autenticado");
        }
        Object principal = authentication.getPrincipal();
        String email = principal instanceof UserDetails ud ? ud.getUsername() : authentication.getName();
        Usuario usuario = usuarioRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));

        Carona carona = caronaRepository.findByIdAtivaWithUsuario(id)
                .orElseThrow(() -> new IllegalArgumentException("Carona não encontrada"));

        if (carona.getUsuario() == null || carona.getUsuario().getId() == null
                || !carona.getUsuario().getId().equals(usuario.getId())) {
            throw new AccessDeniedException("Acesso negado");
        }

        carona.setOrigem(request.getOrigem());
        carona.setDestino(request.getDestino());
        carona.setDataHora(request.getDataHora());
        carona.setVagas(request.getVagas());
        carona.setValor(request.getValor());
        carona.setTelefone(request.getTelefone());
        carona.setObservacao(request.getObservacao());

        Carona salva = caronaRepository.save(carona);
        return caronaMapper.toResponse(salva);
    }
}
