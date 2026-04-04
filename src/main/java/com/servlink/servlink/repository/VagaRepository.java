package com.servlink.servlink.repository;

import com.servlink.servlink.domain.entity.Vaga;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface VagaRepository extends JpaRepository<Vaga, Long> {

    @Query("""
            SELECT v FROM Vaga v
            WHERE v.empresa.id = :empresaId
              AND v.ativo = TRUE
              AND v.status <> com.servlink.servlink.domain.enums.VagaStatus.CANCELADA
            ORDER BY v.dataCriacao DESC
            """)
    List<Vaga> findByEmpresaIdOrderByDataCriacaoDesc(@Param("empresaId") Long empresaId);

    @Query("""
            SELECT v FROM Vaga v
            WHERE v.ativo = TRUE
              AND v.status <> com.servlink.servlink.domain.enums.VagaStatus.CANCELADA
              AND (
                v.expiraEm IS NULL
                OR v.expiraEm > :now
              )
            ORDER BY v.dataCriacao DESC
            """)
    List<Vaga> findAllAtivasNaoExpiradas(@Param("now") LocalDateTime now);
}
