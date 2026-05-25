package com.kampus.kunciruang.repository;

import com.kampus.kunciruang.model.Kelas;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface KelasRepository extends JpaRepository<Kelas, Long> {
    Optional<Kelas> findByNamaKelas(String namaKelas);
}
