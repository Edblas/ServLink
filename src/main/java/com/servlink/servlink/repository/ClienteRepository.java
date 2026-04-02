package com.servlink.servlink.repository;

import com.servlink.servlink.domain.entity.Cliente;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ClienteRepository extends JpaRepository<Cliente, Long> {

    Optional<Cliente> findByUsuarioEmail(String email);

    boolean existsByCnpj(String cnpj);
}
