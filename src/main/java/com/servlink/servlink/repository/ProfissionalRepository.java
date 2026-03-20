package com.servlink.servlink.repository;

import com.servlink.servlink.domain.entity.Profissional;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ProfissionalRepository extends JpaRepository<Profissional, Long> {

    Optional<Profissional> findByUsuarioEmail(String email);

    @Query("""
            SELECT p FROM Profissional p
            WHERE (:cidadeId IS NULL OR p.cidade.id = :cidadeId)
              AND (:categoriaId IS NULL OR p.categoria.id = :categoriaId)
            """)
    Page<Profissional> search(
            @Param("cidadeId") Long cidadeId,
            @Param("categoriaId") Long categoriaId,
            Pageable pageable);
}
