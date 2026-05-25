package com.kampus.kunciruang.controller;

import com.kampus.kunciruang.config.CustomUserDetails;
import com.kampus.kunciruang.dto.response.TransactionResponse;
import com.kampus.kunciruang.model.Transaction;
import com.kampus.kunciruang.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/transactions")
@RequiredArgsConstructor
public class TransactionController {

    private final TransactionRepository transactionRepository;

    @GetMapping
    public ResponseEntity<List<TransactionResponse>> getMyTransactions() {
        CustomUserDetails userDetails = (CustomUserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        Long userId = userDetails.getUser().getId();
        String role = userDetails.getAuthorities().stream()
                .findFirst()
                .map(grantedAuthority -> grantedAuthority.getAuthority().replace("ROLE_", ""))
                .orElse("USER");

        List<Transaction> transactions;
        // Admin gets all transactions, others get their own
        if ("ADMIN".equals(role)) {
            transactions = transactionRepository.findAllByOrderByCreatedAtDesc();
        } else if ("DOSEN".equals(role)) {
            transactions = transactionRepository.findByJadwalDosenIdOrderByCreatedAtDesc(userId);
        } else {
            transactions = transactionRepository.findByUserId(userId);
        }

        List<TransactionResponse> response = transactions.stream()
                .map(TransactionResponse::from)
                .collect(Collectors.toList());

        return ResponseEntity.ok(response);
    }

    @GetMapping("/dosen")
    @PreAuthorize("hasRole('DOSEN')")
    public ResponseEntity<List<TransactionResponse>> getDosenTransactions() {
        CustomUserDetails userDetails = (CustomUserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        Long dosenId = userDetails.getUser().getId();
        List<TransactionResponse> response = transactionRepository.findByJadwalDosenIdOrderByCreatedAtDesc(dosenId)
                .stream().map(TransactionResponse::from).collect(Collectors.toList());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/all")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<TransactionResponse>> getAllTransactions() {
        List<TransactionResponse> response = transactionRepository.findAllByOrderByCreatedAtDesc()
                .stream().map(TransactionResponse::from).collect(Collectors.toList());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<TransactionResponse> getTransaction(@PathVariable Long id) {
        Transaction transaction = transactionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Transaksi tidak ditemukan"));
        return ResponseEntity.ok(TransactionResponse.from(transaction));
    }
}
