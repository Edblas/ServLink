package com.servlink.servlink.repository;

import com.servlink.servlink.domain.entity.Candidatura;
import java.util.List;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface CandidaturaRepository extends JpaRepository<Candidatura, Long> {

    boolean existsByVagaIdAndProfissionalId(Long vagaId, Long profissionalId);

    List<Candidatura> findByVagaIdOrderByDataCandidaturaDesc(Long vagaId);

    List<Candidatura> findByProfissionalIdOrderByDataCandidaturaDesc(Long profissionalId);

    long countByVagaId(Long vagaId);

    @Query("""
            SELECT c.vaga.id, COUNT(c.id)
            FROM Candidatura c
            WHERE c.vaga.id IN :vagaIds
              AND c.ativo = TRUE
            GROUP BY c.vaga.id
            """)
    List<Object[]> countByVagaIds(@Param("vagaIds") List<Long> vagaIds);

    @Modifying
    @Query("""
            UPDATE Candidatura c
            SET c.status = com.servlink.servlink.domain.enums.CandidaturaStatus.RECUSADO
            WHERE c.vaga.id = :vagaId
              AND c.id <> :candidaturaId
            """)
    int recusarOutrasCandidaturasDaVaga(@Param("vagaId") Long vagaId, @Param("candidaturaId") Long candidaturaId);
}
