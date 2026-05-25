package com.kampus.kunciruang.controller;

import com.kampus.kunciruang.dto.request.GenerateQrRequest;
import com.kampus.kunciruang.dto.response.QrResponse;
import com.kampus.kunciruang.service.QrService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/qr")
@RequiredArgsConstructor
public class QrController {

    private final QrService qrService;

    /**
     * Generate atau ambil QR Global Harian (hanya Admin).
     * Jika QR hari ini sudah ada, kembalikan QR yang sama.
     */
    @PostMapping("/generate")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<QrResponse> generateQr(@RequestBody(required = false) GenerateQrRequest request) {
        if (request == null) request = new GenerateQrRequest();
        return ResponseEntity.ok(qrService.generateGlobalDailyQr(request));
    }

    /**
     * Lihat daftar QR aktif hari ini.
     */
    @GetMapping("/today")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<QrResponse> getTodayQr() {
        return ResponseEntity.ok(qrService.getTodayQrWithImage());
    }

    /**
     * Lihat daftar semua QR aktif.
     */
    @GetMapping("/list")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<QrResponse>> listActiveQr() {
        return ResponseEntity.ok(qrService.listTodayActiveQr());
    }

    /**
     * Nonaktifkan QR tertentu.
     */
    @DeleteMapping("/{id}/revoke")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<String> revokeQr(@PathVariable Long id) {
        qrService.revokeQr(id);
        return ResponseEntity.ok("QR berhasil dinonaktifkan");
    }
}
