package com.kampus.kunciruang.service;

import com.kampus.kunciruang.dto.response.ScanResponse;
import com.kampus.kunciruang.exception.QrAlreadyClosedException;
import com.kampus.kunciruang.exception.QrExpiredException;
import com.kampus.kunciruang.model.Jadwal;
import com.kampus.kunciruang.model.QrSession;
import com.kampus.kunciruang.model.Transaction;
import com.kampus.kunciruang.repository.JadwalRepository;
import com.kampus.kunciruang.repository.QrSessionRepository;
import com.kampus.kunciruang.repository.TransactionRepository;
import com.kampus.kunciruang.util.HariUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Optional;

@Service
@Transactional
@RequiredArgsConstructor
public class ScanService {

    private final QrSessionRepository qrSessionRepository;
    private final JadwalRepository jadwalRepository;
    private final TransactionRepository transactionRepository;
    private final com.kampus.kunciruang.repository.UserRepository userRepository;
    private final com.kampus.kunciruang.repository.MahasiswaRepository mahasiswaRepository;

    public ScanResponse processScan(String token, Long userId, Boolean withInfokus) {

        // 1. Validasi token QR
        QrSession session = qrSessionRepository.findByToken(token)
                .orElseThrow(() -> new RuntimeException("QR tidak valid atau tidak ditemukan"));

        if (!session.isActive()) {
            throw new QrExpiredException("QR sudah dinonaktifkan oleh admin");
        }
        if (session.getExpiredAt().isBefore(LocalDateTime.now())) {
            throw new QrExpiredException("QR sudah kadaluarsa");
        }

        // Ambil User
        com.kampus.kunciruang.model.User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User tidak ditemukan"));

        // 2. Tentukan hari dan jam sekarang
        LocalDateTime now = LocalDateTime.now();
        String hari = HariUtil.toIndonesian(now.getDayOfWeek());
        LocalTime jamScan = now.toLocalTime();

        // 3. Auto-lookup jadwal dari database
        Optional<Jadwal> jadwalOpt = Optional.empty();
        if (session.getRoom() != null) {
            jadwalOpt = jadwalRepository.findAktifByRoomHariJam(
                    session.getRoom().getId(),
                    hari,
                    jamScan
            );
        } else {
            // QR Global, cari berdasarkan kelas user
            Optional<com.kampus.kunciruang.model.Mahasiswa> mhsOpt = mahasiswaRepository.findByUserId(userId);
            if (mhsOpt.isPresent() && mhsOpt.get().getKelas() != null) {
                jadwalOpt = jadwalRepository.findAktifByKelasHariJam(
                        mhsOpt.get().getKelas().getId(),
                        hari,
                        jamScan
                );
            }
        }

        if (jadwalOpt.isEmpty() && session.getRoom() == null) {
            throw new RuntimeException("Tidak ada jadwal kelas aktif untuk Anda saat ini.");
        }

        // 4. Resolve data jadwal
        Jadwal jadwal = jadwalOpt.orElse(null);
        String dosenSnapshot = jadwal != null && jadwal.getDosen() != null ? jadwal.getDosen().getFullName() : "Tidak ada jadwal";
        String mataKuliahSnapshot = jadwal != null && jadwal.getMataKuliah() != null ? jadwal.getMataKuliah().getNamaMatkul() : "Tidak ada jadwal";
        String kelasSnapshot = jadwal != null && jadwal.getKelas() != null ? jadwal.getKelas().getNamaKelas() : "Tidak ada jadwal";

        // 5. Cek apakah user masih punya pinjaman AMBIL yang aktif (dari session manapun)
        Optional<Transaction> existing = transactionRepository.findByUserIdAndStatus(userId, "AMBIL");

        if (existing.isEmpty()) {
            // AMBIL baru
            Transaction trx = new Transaction();
            trx.setQrSession(session);
            trx.setJadwal(jadwal);
            trx.setUserId(userId);
            trx.setDosenSnapshot(dosenSnapshot);
            trx.setMataKuliahSnapshot(mataKuliahSnapshot);
            trx.setKelasSnapshot(kelasSnapshot);
            trx.setWaktuAmbil(now);
            trx.setStatus("AMBIL");
            trx.setWithInfokus(withInfokus != null ? withInfokus : false);
            transactionRepository.save(trx);

            return ScanResponse.builder()
                    .status("AMBIL")
                    .message("Kunci berhasil diambil")
                    .transactionId(trx.getId())
                    .roomCode(jadwal != null && jadwal.getRoom() != null ? jadwal.getRoom().getNamaRuang() : "-")
                    .roomName(jadwal != null && jadwal.getRoom() != null ? jadwal.getRoom().getNamaRuang() : "Semua Ruangan")
                    .dosen(dosenSnapshot)
                    .mataKuliah(mataKuliahSnapshot)
                    .kelas(kelasSnapshot)
                    .withInfokus(withInfokus != null ? withInfokus : false)
                    .waktuAmbil(now)
                    .build();

        } else {
            Transaction trx = existing.get();

            // KEMBALI
            trx.setWaktuKembali(now);
            trx.setStatus("KEMBALI");
            transactionRepository.save(trx);

            long menitDurasi = Duration.between(trx.getWaktuAmbil(), now).toMinutes();
            String durasi = menitDurasi >= 60
                    ? (menitDurasi / 60) + " jam " + (menitDurasi % 60) + " menit"
                    : menitDurasi + " menit";

            return ScanResponse.builder()
                    .status("KEMBALI")
                    .message("Kunci berhasil dikembalikan")
                    .transactionId(trx.getId())
                    .roomCode(jadwal != null && jadwal.getRoom() != null ? jadwal.getRoom().getNamaRuang() : "-")
                    .durasi(durasi)
                    .waktuKembali(now)
                    .build();
        }
    }
}
