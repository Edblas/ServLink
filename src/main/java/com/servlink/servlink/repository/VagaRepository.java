package com.servlink.servlink.repository;

import com.servlink.servlink.domain.entity.Vaga;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VagaRepository extends JpaRepository<Vaga, Long> {

    List<Vaga> findByEmpresaIdOrderByDataCriacaoDesc(Long empresaId);

    List<Vaga> findAllByOrderByDataCriacaoDesc();
}

