package com.kampus.kunciruang.service;

import com.kampus.kunciruang.config.CustomUserDetails;
import com.kampus.kunciruang.dto.request.GenerateQrRequest;
import com.kampus.kunciruang.dto.response.QrResponse;
import com.kampus.kunciruang.model.QrSession;
import com.kampus.kunciruang.model.User;
import com.kampus.kunciruang.repository.QrSessionRepository;
import com.kampus.kunciruang.util.QrCodeGenerator;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@Transactional
@RequiredArgsConstructor
public class QrService {

    private final QrSessionRepository qrSessionRepository;
    private final QrCodeGenerator qrCodeGenerator;
    private final com.kampus.kunciruang.repository.RoomRepository roomRepository;

    /**
     * Generate atau ambil kembali QR Global Harian.
     * 1 QR untuk semua ruangan, berlaku sampai jam 23:59:59 hari ini.
     * Jika sudah ada QR hari ini (aktif), kembalikan yang sama.
     */
    public QrResponse generateGlobalDailyQr(GenerateQrRequest request) {
        LocalDate today = (request.getDate() != null && !request.getDate().isBlank())
                ? LocalDate.parse(request.getDate())
                : LocalDate.now();

        // Cek apakah sudah ada QR global untuk hari ini
        Optional<QrSession> existing = qrSessionRepository.findFirstBySessionDateOrderByCreatedAtDesc(today);
        if (existing.isPresent()) {
            QrSession session = existing.get();
            String qrImage = qrCodeGenerator.generateQrCodeBase64(session.getToken(), 400, 400);
            return buildQrResponse(session, qrImage);
        }

        CustomUserDetails userDetails = (CustomUserDetails) SecurityContextHolder.getContext()
                .getAuthentication().getPrincipal();
        User adminUser = userDetails.getUser();

        QrSession session = new QrSession();
        session.setToken(UUID.randomUUID().toString().replace("-", ""));
        session.setRoom(null); // Global
        session.setSessionDate(today);
        session.setActive(true);
        session.setCreatedBy(adminUser);
        session.setCreatedAt(LocalDateTime.now());
        session.setExpiredAt(today.atTime(23, 59, 59));

        session = qrSessionRepository.save(session);
        String qrImage = qrCodeGenerator.generateQrCodeBase64(session.getToken(), 400, 400);

        log.info("QR Global Harian dibuat tanggal {} oleh Admin {}", today, adminUser.getEmail());

        return buildQrResponse(session, qrImage);
    }

    public List<QrResponse> listTodayActiveQr() {
        LocalDate today = LocalDate.now();
        return qrSessionRepository.findByActiveTrueAndSessionDateOrderByCreatedAtDesc(today)
                .stream()
                .map(session -> buildQrResponse(session, null))
                .collect(Collectors.toList());
    }

    public QrResponse getTodayQrWithImage() {
        LocalDate today = LocalDate.now();
        Optional<QrSession> existing = qrSessionRepository.findFirstBySessionDateOrderByCreatedAtDesc(today);
        if (existing.isEmpty()) {
            throw new RuntimeException("Belum ada QR untuk hari ini. Silakan generate terlebih dahulu.");
        }
        QrSession session = existing.get();
        String qrImage = qrCodeGenerator.generateQrCodeBase64(session.getToken(), 400, 400);
        return buildQrResponse(session, qrImage);
    }

    public void revokeQr(Long id) {
        QrSession session = qrSessionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("QR Session tidak ditemukan"));
        session.setActive(false);
        qrSessionRepository.save(session);
        log.info("QR Session {} dinonaktifkan", id);
    }

    /**
     * Jadwal otomatis: Reset/nonaktifkan semua QR kemarin setiap jam 00:01 WIB.
     * Cron: detik menit jam hari bulan tahun
     */
    @Scheduled(cron = "0 1 0 * * *") // setiap hari jam 00:01:00
    public void autoExpireYesterdayQr() {
        LocalDate yesterday = LocalDate.now().minusDays(1);
        List<QrSession> oldSessions = qrSessionRepository
                .findByActiveTrueAndSessionDateOrderByCreatedAtDesc(yesterday);
        for (QrSession s : oldSessions) {
            s.setActive(false);
            qrSessionRepository.save(s);
        }
        log.info("Auto-expire: {} QR dari kemarin ({}) telah dinonaktifkan", oldSessions.size(), yesterday);
    }

    private QrResponse buildQrResponse(QrSession session, String qrImage) {
        String namaRuang = session.getRoom() != null ? session.getRoom().getNamaRuang() : "QR Global Harian";

        return QrResponse.builder()
                .token(session.getToken())
                .roomCode("-")
                .roomName(namaRuang)
                .sessionDate(session.getSessionDate())
                .expiredAt(session.getExpiredAt())
                .qrImageBase64(qrImage)
                .build();
    }
}
