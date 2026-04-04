package com.servlink.servlink.service.impl;

import com.servlink.servlink.domain.entity.Categoria;
import com.servlink.servlink.domain.entity.Cidade;
import com.servlink.servlink.domain.entity.Profissional;
import com.servlink.servlink.domain.entity.Usuario;
import com.servlink.servlink.domain.enums.Plano;
import com.servlink.servlink.domain.enums.Role;
import com.servlink.servlink.dto.request.ProfissionalPerfilRequest;
import com.servlink.servlink.dto.request.ProfissionalRequest;
import com.servlink.servlink.dto.response.ProfissionalResponse;
import com.servlink.servlink.mapper.ProfissionalMapper;
import com.servlink.servlink.repository.CategoriaRepository;
import com.servlink.servlink.repository.CidadeRepository;
import com.servlink.servlink.repository.ProfissionalRepository;
import com.servlink.servlink.repository.UsuarioRepository;
import com.servlink.servlink.service.ProfissionalService;
import jakarta.transaction.Transactional;
import java.math.BigDecimal;
import java.util.Optional;
import java.util.UUID;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Service
public class ProfissionalServiceImpl implements ProfissionalService {

    private final ProfissionalRepository profissionalRepository;
    private final UsuarioRepository usuarioRepository;
    private final CidadeRepository cidadeRepository;
    private final CategoriaRepository categoriaRepository;
    private final ProfissionalMapper profissionalMapper;

    @Value("${servlink.uploads.dir:uploads}")
    private String uploadsDir;

    public ProfissionalServiceImpl(
            ProfissionalRepository profissionalRepository,
            UsuarioRepository usuarioRepository,
            CidadeRepository cidadeRepository,
            CategoriaRepository categoriaRepository,
            ProfissionalMapper profissionalMapper) {
        this.profissionalRepository = profissionalRepository;
        this.usuarioRepository = usuarioRepository;
        this.cidadeRepository = cidadeRepository;
        this.categoriaRepository = categoriaRepository;
        this.profissionalMapper = profissionalMapper;
    }

    @Override
    @Transactional
    public ProfissionalResponse criar(ProfissionalRequest request) {
        Usuario usuario = usuarioRepository.findById(request.getUsuarioId())
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));

        if (usuario.getRole() != Role.PROFISSIONAL) {
            throw new IllegalArgumentException("Usuário precisa ter perfil PROFISSIONAL");
        }

        Cidade cidade = cidadeRepository.findById(request.getCidadeId())
                .orElseThrow(() -> new IllegalArgumentException("Cidade não encontrada"));

        Categoria categoria = categoriaRepository.findById(request.getCategoriaId())
                .orElseThrow(() -> new IllegalArgumentException("Categoria não encontrada"));

        Profissional profissional = new Profissional();
        profissional.setUsuario(usuario);
        profissional.setDescricao(request.getDescricao());
        profissional.setFotoUrl(request.getFotoUrl());
        profissional.setAnosExperiencia(request.getAnosExperiencia());
        profissional.setIdade(request.getIdade());
        profissional.setTipoPagamento(request.getTipoPagamento());
        profissional.setInstagramUrl(request.getInstagramUrl());
        profissional.setTiktokUrl(request.getTiktokUrl());
        profissional.setSiteUrl(request.getSiteUrl());
        profissional.setEndereco(request.getEndereco());
        if (request.getCep() != null) {
            String cep = request.getCep().replaceAll("[^0-9]", "").trim();
            if (!cep.isEmpty() && cep.length() != 8) {
                throw new IllegalArgumentException("CEP inválido");
            }
            profissional.setCep(cep.isEmpty() ? null : cep);
        }
        if (request.getNumero() != null) {
            String numero = request.getNumero().trim();
            profissional.setNumero(numero.isEmpty() ? null : numero);
        }
        if (request.getComplemento() != null) {
            String complemento = request.getComplemento().trim();
            profissional.setComplemento(complemento.isEmpty() ? null : complemento);
        }
        profissional.setBairro(request.getBairro());
        profissional.setCarteiraMotorista(Boolean.FALSE);
        profissional.setPlano(request.getPlano());
        profissional.setCidade(cidade);
        profissional.setCategoria(categoria);
        profissional.setMediaAvaliacoes(BigDecimal.ZERO);
        profissional.setAtivo(true);

        Profissional salvo = profissionalRepository.save(profissional);
        return profissionalMapper.toResponse(salvo);
    }

    @Override
    @Transactional
    @PreAuthorize("hasRole('PROFISSIONAL')")
    public ProfissionalResponse criarOuObterProfissionalAtual() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new IllegalStateException("Usuário não autenticado");
        }

        String email = authentication.getName();

        Optional<Profissional> existente = profissionalRepository.findByUsuarioEmail(email);
        if (existente.isPresent()) {
            return profissionalMapper.toResponse(existente.get());
        }

        Usuario usuario = usuarioRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));

        if (usuario.getRole() != Role.PROFISSIONAL) {
            throw new IllegalArgumentException("Usuário precisa ter perfil PROFISSIONAL");
        }

        Profissional profissional = new Profissional();
        profissional.setUsuario(usuario);
        profissional.setDescricao("Atualize seu perfil");
        profissional.setPlano(Plano.BASICO);
        profissional.setMediaAvaliacoes(BigDecimal.ZERO);
        profissional.setAtivo(true);

        Profissional salvo = profissionalRepository.save(profissional);
        return profissionalMapper.toResponse(salvo);
    }

    @Override
    @PreAuthorize("hasRole('PROFISSIONAL')")
    public ProfissionalResponse obterProfissionalAtual() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new IllegalStateException("Usuário não autenticado");
        }

        String email = authentication.getName();

        Profissional profissional = profissionalRepository.findByUsuarioEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Profissional não encontrado"));

        return profissionalMapper.toResponse(profissional);
    }

    @Override
    @Transactional
    @PreAuthorize("hasRole('PROFISSIONAL')")
    public ProfissionalResponse atualizarProfissionalAtual(ProfissionalPerfilRequest request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new IllegalStateException("Usuário não autenticado");
        }

        String email = authentication.getName();

        Profissional profissional = profissionalRepository.findByUsuarioEmail(email)
                .orElseGet(() -> {
                    Usuario usuario = usuarioRepository.findByEmail(email)
                            .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));

                    if (usuario.getRole() != Role.PROFISSIONAL) {
                        throw new IllegalArgumentException("Usuário precisa ter perfil PROFISSIONAL");
                    }

                    Profissional novo = new Profissional();
                    novo.setUsuario(usuario);
                    novo.setDescricao("Atualize seu perfil");
                    novo.setPlano(Plano.BASICO);
                    novo.setMediaAvaliacoes(BigDecimal.ZERO);
                    novo.setAtivo(true);
                    return profissionalRepository.save(novo);
                });

        if (request.getNome() != null) {
            String nome = request.getNome().trim();
            if (nome.isEmpty()) {
                throw new IllegalArgumentException("Nome não pode ser vazio");
            }
            Usuario usuario = profissional.getUsuario();
            usuario.setNome(nome);
            usuarioRepository.save(usuario);
        }

        if (request.getTelefone() != null) {
            String telefone = request.getTelefone().trim();
            if (telefone.isEmpty()) {
                throw new IllegalArgumentException("Telefone não pode ser vazio");
            }
            Usuario usuario = profissional.getUsuario();
            usuario.setTelefone(telefone);
            usuarioRepository.save(usuario);
        }

        if (request.getDescricao() != null) {
            String descricao = request.getDescricao().trim();
            if (descricao.isEmpty()) {
                throw new IllegalArgumentException("Descrição não pode ser vazia");
            }
            profissional.setDescricao(descricao);
        }

        if (request.getFotoUrl() != null) {
            String fotoUrl = request.getFotoUrl().trim();
            profissional.setFotoUrl(fotoUrl.isEmpty() ? null : fotoUrl);
        }

        if (request.getBairro() != null) {
            String bairro = request.getBairro().trim();
            profissional.setBairro(bairro.isEmpty() ? null : bairro);
        }

        if (request.getCarteiraMotorista() != null) {
            profissional.setCarteiraMotorista(request.getCarteiraMotorista());
        }

        if (request.getAnosExperiencia() != null) {
            profissional.setAnosExperiencia(request.getAnosExperiencia());
        }

        if (request.getIdade() != null) {
            profissional.setIdade(request.getIdade());
        }

        if (request.getTipoPagamento() != null) {
            profissional.setTipoPagamento(request.getTipoPagamento());
        }

        if (request.getInstagramUrl() != null) {
            String instagramUrl = request.getInstagramUrl().trim();
            profissional.setInstagramUrl(instagramUrl.isEmpty() ? null : instagramUrl);
        }

        if (request.getTiktokUrl() != null) {
            String tiktokUrl = request.getTiktokUrl().trim();
            profissional.setTiktokUrl(tiktokUrl.isEmpty() ? null : tiktokUrl);
        }

        if (request.getSiteUrl() != null) {
            String siteUrl = request.getSiteUrl().trim();
            profissional.setSiteUrl(siteUrl.isEmpty() ? null : siteUrl);
        }

        if (request.getEndereco() != null) {
            String endereco = request.getEndereco().trim();
            profissional.setEndereco(endereco.isEmpty() ? null : endereco);
        }

        if (request.getCep() != null) {
            String cep = request.getCep().replaceAll("[^0-9]", "").trim();
            if (!cep.isEmpty() && cep.length() != 8) {
                throw new IllegalArgumentException("CEP inválido");
            }
            profissional.setCep(cep.isEmpty() ? null : cep);
        }

        if (request.getNumero() != null) {
            String numero = request.getNumero().trim();
            profissional.setNumero(numero.isEmpty() ? null : numero);
        }

        if (request.getComplemento() != null) {
            String complemento = request.getComplemento().trim();
            profissional.setComplemento(complemento.isEmpty() ? null : complemento);
        }

        if (request.getCidadeId() != null) {
            Cidade cidade = cidadeRepository.findById(request.getCidadeId())
                    .orElseThrow(() -> new IllegalArgumentException("Cidade não encontrada"));
            profissional.setCidade(cidade);
        }

        if (request.getCategoriaId() != null) {
            Categoria categoria = categoriaRepository.findById(request.getCategoriaId())
                    .orElseThrow(() -> new IllegalArgumentException("Categoria não encontrada"));
            profissional.setCategoria(categoria);
        }

        Profissional salvo = profissionalRepository.save(profissional);
        return profissionalMapper.toResponse(salvo);
    }

    @Override
    public Page<ProfissionalResponse> buscar(Long cidadeId, Long categoriaId, String q, String bairro, int pagina, int tamanho) {
        Sort sort = Sort.by(
                Sort.Order.desc("mediaAvaliacoes").nullsLast(),
                Sort.Order.desc("dataCriacao"));

        Pageable pageable = PageRequest.of(pagina, tamanho, sort);

        String queryLike = q == null || q.isBlank() ? null : "%" + q.trim() + "%";
        String bairroLike = bairro == null || bairro.isBlank() ? null : "%" + bairro.trim() + "%";

        return profissionalRepository.search(cidadeId, categoriaId, queryLike, bairroLike, pageable)
                .map(profissionalMapper::toResponse);
    }

    @Override
    @Transactional
    @PreAuthorize("hasRole('PROFISSIONAL')")
    public ProfissionalResponse atualizarFotoAtual(MultipartFile file) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new IllegalStateException("Usuário não autenticado");
        }
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("Arquivo inválido");
        }
        String email = authentication.getName();
        Profissional profissional = profissionalRepository.findByUsuarioEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Profissional não encontrado"));

        Path dir = Paths.get(uploadsDir).resolve("profissionais").normalize();
        try {
            Files.createDirectories(dir);
        } catch (IOException e) {
            throw new IllegalStateException("Falha ao preparar diretório de uploads");
        }

        String original = file.getOriginalFilename();
        String ext = ".jpg";
        if (original != null && original.contains(".")) {
            String candidate = original.substring(original.lastIndexOf('.')).toLowerCase();
            if (candidate.matches("\\.[a-z0-9]{1,5}")) {
                ext = candidate;
            }
        }
        if (".jpg".equals(ext) || ".jpeg".equals(ext)) {
            ext = ".jpg";
        }
        String timestamp = DateTimeFormatter.ofPattern("yyyyMMddHHmmss").format(LocalDateTime.now());
        String filename = "profissional-" + profissional.getId() + "-" + timestamp + "-" + UUID.randomUUID() + ext;
        Path target = dir.resolve(filename);
        try {
            file.transferTo(target);
        } catch (IOException e) {
            throw new IllegalStateException("Falha ao salvar arquivo");
        }

        String url = "/uploads/profissionais/" + filename;
        profissional.setFotoUrl(url);
        Profissional salvo = profissionalRepository.save(profissional);
        return profissionalMapper.toResponse(salvo);
    }
}
