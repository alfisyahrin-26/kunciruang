package com.kampus.kunciruang.repository;

import com.kampus.kunciruang.model.Jadwal;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface JadwalRepository extends JpaRepository<Jadwal, Long> {

    @Query("""
        SELECT j FROM Jadwal j
        WHERE j.room.id = :roomId
          AND j.hari = :hari
          AND :jamSekarang >= j.jamMulai
          AND :jamSekarang <= j.jamSelesai
        ORDER BY j.jamMulai ASC LIMIT 1
    """)
    Optional<Jadwal> findAktifByRoomHariJam(
        @Param("roomId")      Long roomId,
        @Param("hari")        String hari,
        @Param("jamSekarang") LocalTime jamSekarang
    );

    @Query("""
        SELECT j FROM Jadwal j
        WHERE j.room.id = :roomId
          AND j.hari = :hari
        ORDER BY j.jamMulai ASC
    """)
    List<Jadwal> findByRoomAndHari(
        @Param("roomId") Long roomId,
        @Param("hari")   String hari
    );
    @Query("""
        SELECT j FROM Jadwal j
        WHERE j.kelas.id = :kelasId
          AND j.hari = :hari
          AND :jamSekarang >= j.jamMulai
          AND :jamSekarang <= j.jamSelesai
        ORDER BY j.jamMulai ASC LIMIT 1
    """)
    Optional<Jadwal> findAktifByKelasHariJam(
        @Param("kelasId")     Long kelasId,
        @Param("hari")        String hari,
        @Param("jamSekarang") LocalTime jamSekarang
    );
}
