package com.kampus.kunciruang.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "transactions")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Transaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "qr_session_id", nullable = false)
    private QrSession qrSession;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "jadwal_id")
    private Jadwal jadwal;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "dosen_snapshot", length = 200)
    private String dosenSnapshot;

    @Column(name = "mata_kuliah_snapshot", length = 200)
    private String mataKuliahSnapshot;

    @Column(name = "kelas_snapshot", length = 50)
    private String kelasSnapshot;

    @Column(name = "waktu_ambil")
    private LocalDateTime waktuAmbil;

    @Column(name = "waktu_kembali")
    private LocalDateTime waktuKembali;

    @Column(nullable = false, length = 20)
    private String status = "AMBIL";

    @Column(name = "with_infokus", nullable = false)
    private Boolean withInfokus = false;

    @Column(columnDefinition = "TEXT")
    private String keterangan;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();

    @PreUpdate
    public void setUpdatedAt() {
        this.updatedAt = LocalDateTime.now();
    }
}
