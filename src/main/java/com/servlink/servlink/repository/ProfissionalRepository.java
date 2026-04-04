package com.servlink.servlink.repository;

import com.servlink.servlink.domain.entity.Profissional;
import com.servlink.servlink.dto.response.CategoriaCountResponse;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ProfissionalRepository extends JpaRepository<Profissional, Long> {

    Optional<Profissional> findByUsuarioEmail(String email);

    @EntityGraph(attributePaths = {"usuario", "cidade", "categoria"})
    @Query("""
            SELECT p FROM Profissional p
            JOIN p.usuario u
            LEFT JOIN p.cidade ci
            LEFT JOIN p.categoria c
            WHERE (:cidadeId IS NULL OR ci.id = :cidadeId)
              AND (:categoriaId IS NULL OR c.id = :categoriaId)
              AND (:bairro IS NULL OR LOWER(COALESCE(p.bairro, '')) LIKE LOWER(CONCAT('%', :bairro, '%')))
              AND (
                :q IS NULL
                OR LOWER(u.nome) LIKE LOWER(CONCAT('%', :q, '%'))
                OR LOWER(COALESCE(c.nome, '')) LIKE LOWER(CONCAT('%', :q, '%'))
              )
            """)
    Page<Profissional> search(
            @Param("cidadeId") Long cidadeId,
            @Param("categoriaId") Long categoriaId,
            @Param("q") String q,
            @Param("bairro") String bairro,
            Pageable pageable);

    @Query("""
            SELECT new com.servlink.servlink.dto.response.CategoriaCountResponse(
              c.id,
              COUNT(p.id)
            )
            FROM Profissional p
            JOIN p.categoria c
            LEFT JOIN p.cidade ci
            WHERE (:cidadeId IS NULL OR ci.id = :cidadeId)
              AND p.ativo = TRUE
            GROUP BY c.id
            """)
    List<CategoriaCountResponse> countByCategoria(@Param("cidadeId") Long cidadeId);
}
