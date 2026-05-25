package com.kampus.kunciruang.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "mata_kuliahs")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MataKuliah {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "kode_matkul", unique = true, nullable = false, length = 255)
    private String kodeMatkul;

    @Column(name = "nama_matkul", nullable = false, length = 255)
    private String namaMatkul;

    private Integer sks;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
