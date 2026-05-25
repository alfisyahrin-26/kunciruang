package com.kampus.kunciruang.repository;

import com.kampus.kunciruang.model.QrSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface QrSessionRepository extends JpaRepository<QrSession, Long> {
    Optional<QrSession> findByToken(String token);
    List<QrSession> findByActiveTrue();
    Optional<QrSession> findByRoomIdAndSessionDate(Long roomId, LocalDate sessionDate);
    Optional<QrSession> findFirstBySessionDateOrderByCreatedAtDesc(LocalDate sessionDate);
    List<QrSession> findByActiveTrueAndSessionDateOrderByCreatedAtDesc(LocalDate sessionDate);
}
