package com.servlink.servlink.repository;

import com.servlink.servlink.domain.entity.Avaliacao;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface AvaliacaoRepository extends JpaRepository<Avaliacao, Long> {

    boolean existsByClienteIdAndProfissionalId(Long clienteId, Long profissionalId);

    @Query("SELECT COALESCE(AVG(a.nota), 0) FROM Avaliacao a WHERE a.profissional.id = :profissionalId")
    Double calcularMediaPorProfissional(@Param("profissionalId") Long profissionalId);

    List<Avaliacao> findByProfissionalIdOrderByDataCriacaoDesc(Long profissionalId);
}
