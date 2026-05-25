package com.kampus.kunciruang.repository;

import com.kampus.kunciruang.model.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    Optional<Transaction> findByQrSessionId(Long qrSessionId);
    Optional<Transaction> findByUserIdAndStatus(Long userId, String status);
    Optional<Transaction> findByUserIdAndQrSessionIdAndStatus(Long userId, Long qrSessionId, String status);
    List<Transaction> findByUserId(Long userId);
    List<Transaction> findAllByOrderByCreatedAtDesc();
    List<Transaction> findByJadwalDosenIdOrderByCreatedAtDesc(Long dosenId);
}
