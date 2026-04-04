package com.servlink.servlink.repository;

import com.servlink.servlink.domain.entity.Carona;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface CaronaRepository extends JpaRepository<Carona, Long> {
    @EntityGraph(attributePaths = {"usuario"})
    List<Carona> findAllByAtivoTrueOrderByDataCriacaoDesc();

    @Query("""
            SELECT c
            FROM Carona c
            LEFT JOIN FETCH c.usuario
            WHERE c.id = :id
              AND c.ativo = TRUE
            """)
    Optional<Carona> findByIdAtivaWithUsuario(@Param("id") Long id);
}
