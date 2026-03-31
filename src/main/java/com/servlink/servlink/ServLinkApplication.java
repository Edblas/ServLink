package com.servlink.servlink;

import com.servlink.servlink.domain.entity.Categoria;
import com.servlink.servlink.domain.entity.Cidade;
import com.servlink.servlink.domain.entity.Usuario;
import com.servlink.servlink.domain.enums.Role;
import com.servlink.servlink.repository.CategoriaRepository;
import com.servlink.servlink.repository.CidadeRepository;
import com.servlink.servlink.repository.UsuarioRepository;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.security.crypto.password.PasswordEncoder;

@SpringBootApplication
public class ServLinkApplication {

    public static void main(String[] args) {
        SpringApplication.run(ServLinkApplication.class, args);
    }

    @Bean
    @ConditionalOnProperty(name = "app.seed.enabled", havingValue = "true", matchIfMissing = true)
    CommandLineRunner seedBaseData(
            CidadeRepository cidadeRepository,
            CategoriaRepository categoriaRepository,
            UsuarioRepository usuarioRepository,
            PasswordEncoder passwordEncoder) {
        return args -> {
            seedCidade(cidadeRepository, "Alfenas", "MG");
            seedCidade(cidadeRepository, "Belo Horizonte", "MG");
            seedCidade(cidadeRepository, "São Paulo", "SP");

            if (categoriaRepository.count() == 0) {
                Categoria eletricista = new Categoria();
                eletricista.setNome("Eletricista");
                eletricista.setDescricao("Serviços elétricos residenciais e comerciais");
                categoriaRepository.save(eletricista);

                Categoria diarista = new Categoria();
                diarista.setNome("Diarista");
                diarista.setDescricao("Limpeza e organização");
                categoriaRepository.save(diarista);
            }

            usuarioRepository.findByEmail("teste@servlink.com").orElseGet(() -> {
                Usuario usuario = new Usuario();
                usuario.setNome("Empresa Teste");
                usuario.setEmail("teste@servlink.com");
                usuario.setTelefone("000000000");
                usuario.setSenha(passwordEncoder.encode("123456"));
                usuario.setRole(Role.PROFISSIONAL);
                usuario.setAtivo(true);
                return usuarioRepository.save(usuario);
            });
        };
    }

    private static Cidade seedCidade(CidadeRepository cidadeRepository, String nome, String estado) {
        return cidadeRepository.findByNomeIgnoreCaseAndEstadoIgnoreCase(nome, estado).orElseGet(() -> {
            Cidade cidade = new Cidade();
            cidade.setNome(nome);
            cidade.setEstado(estado);
            return cidadeRepository.save(cidade);
        });
    }
}
