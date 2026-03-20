package com.servlink.servlink.repository;

import com.servlink.servlink.domain.entity.Cidade;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CidadeRepository extends JpaRepository<Cidade, Long> {
    Optional<Cidade> findByNomeIgnoreCaseAndEstadoIgnoreCase(String nome, String estado);
}
