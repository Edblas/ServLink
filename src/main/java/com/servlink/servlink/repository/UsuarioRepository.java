package com.servlink.servlink.repository;

import com.servlink.servlink.domain.entity.Usuario;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    Optional<Usuario> findByEmail(String email);

    boolean existsByEmail(String email);

    @Query("select u from Usuario u where lower(trim(u.email)) = lower(trim(:email)) order by u.id asc")
    List<Usuario> findAllByEmailNormalized(@Param("email") String email);
}
