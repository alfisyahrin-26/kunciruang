package com.kampus.kunciruang.repository;

import com.kampus.kunciruang.model.MataKuliah;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface MataKuliahRepository extends JpaRepository<MataKuliah, Long> {
    Optional<MataKuliah> findByKodeMatkul(String kodeMatkul);
    Optional<MataKuliah> findByNamaMatkul(String namaMatkul);
}
