package com.servlink.servlink.repository;

import com.servlink.servlink.domain.entity.Carona;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CaronaRepository extends JpaRepository<Carona, Long> {
    List<Carona> findAllByOrderByDataCriacaoDesc();
}
