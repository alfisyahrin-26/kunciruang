# CLAUDE.md — Blueprint Sistem Peminjaman Kunci Ruang Kampus
> Stack: Flutter + Spring Boot + PostgreSQL
> Design Pattern: Factory Method (QR Generation)
> Auth: JWT
> Versi: 2.0 — Integrasi Database Jadwal (Auto-Lookup, Zero Manual Input)
> database saya ada di mysql phpmyadmin dengan username pas login root dan password kosong dan nama databse saya manajemen_ruangan_db

---

## 📌 Ringkasan Sistem

Sistem peminjaman kunci ruang berbasis QR per hari. Admin generate QR untuk setiap ruangan.
Mahasiswa/dosen scan QR → sistem **otomatis lookup jadwal** berdasarkan ruangan + hari + jam → langsung catat AMBIL/KEMBALI.

**Tidak ada input manual dari user.** Semua data (dosen, mata kuliah, kelas) diambil otomatis dari tabel `jadwals`.

---

## 🔑 Konsep Inti: Mengapa Tidak Perlu Input Manual

Database `jadwals` sudah memiliki semua data yang dibutuhkan:

```
jadwals
  ├── room_id       → ruangan mana (dari QR)
  ├── dosen_id      → dosen siapa (auto-lookup)
  ├── mata_kuliah_id → mata kuliah apa (auto-lookup)
  ├── class_id      → kelas mana (auto-lookup)
  ├── hari          → Senin/Selasa/... (dari waktu scan)
  ├── jam_mulai     → misal 07:30:00
  └── jam_selesai   → misal 10:00:00
```

Saat user scan QR, backend tinggal query:
> "Cari jadwal di room X, hari ini, di mana jam sekarang ada di antara jam_mulai dan jam_selesai"

Ketemu → ambil semua datanya → simpan transaksi. Selesai.

---

## 🏗️ Factory Method — Posisi & Alasan

### Mengapa Factory Method untuk QR?

Setiap ruangan/sesi bisa punya karakteristik generate QR yang berbeda. Dengan Factory Method:
- Tambah tipe sesi baru → tambah class baru saja, tanpa ubah kode lama
- Mengikuti Open/Closed Principle
- Logic generate token tetap terisolasi

### Posisi dalam arsitektur:

```
QrController
    └── QrService
            └── QrCreatorFactory          ← dispatcher
                    ├── MorningQrCreator  ← 07:30–12:00
                    ├── AfternoonQrCreator← 12:00–16:00
                    └── EveningQrCreator  ← 16:00–18:00
```

> Catatan: QrSession yang di-generate hanya butuh token + room_id.
> Jadwal (dosen, MK, kelas) di-resolve saat scan, bukan saat generate QR.

---

## 📁 Struktur Folder Lengkap

```
kunci-ruang/
│
├── backend/
│   └── src/main/
│       ├── java/com/kampus/kunciruang/
│       │   │
│       │   ├── KunciRuangApplication.java
│       │   │
│       │   ├── config/
│       │   │   ├── SecurityConfig.java
│       │   │   ├── JwtConfig.java
│       │   │   └── CorsConfig.java
│       │   │
│       │   ├── controller/
│       │   │   ├── AuthController.java
│       │   │   ├── QrController.java
│       │   │   ├── ScanController.java
│       │   │   └── TransactionController.java
│       │   │
│       │   ├── service/
│       │   │   ├── AuthService.java
│       │   │   ├── QrService.java
│       │   │   ├── ScanService.java          ← logika auto-lookup jadwal
│       │   │   └── TransactionService.java
│       │   │
│       │   ├── factory/                      ← ⭐ FACTORY METHOD
│       │   │   ├── QrSessionCreator.java     (abstract)
│       │   │   ├── MorningQrCreator.java     (07:30–12:00)
│       │   │   ├── AfternoonQrCreator.java   (12:00–16:00)
│       │   │   ├── EveningQrCreator.java     (16:00–18:00)
│       │   │   └── QrCreatorFactory.java     (dispatcher)
│       │   │
│       │   ├── model/
│       │   │   ├── User.java
│       │   │   ├── Room.java
│       │   │   ├── MataKuliah.java
│       │   │   ├── Kelas.java
│       │   │   ├── Jadwal.java               ← ⭐ model jadwal dari DB existing
│       │   │   ├── QrSession.java
│       │   │   └── Transaction.java
│       │   │
│       │   ├── repository/
│       │   │   ├── UserRepository.java
│       │   │   ├── RoomRepository.java
│       │   │   ├── MataKuliahRepository.java
│       │   │   ├── KelasRepository.java
│       │   │   ├── JadwalRepository.java     ← ⭐ query auto-lookup
│       │   │   ├── QrSessionRepository.java
│       │   │   └── TransactionRepository.java
│       │   │
│       │   ├── dto/
│       │   │   ├── request/
│       │   │   │   ├── LoginRequest.java
│       │   │   │   ├── GenerateQrRequest.java
│       │   │   │   └── ScanRequest.java      ← hanya butuh token sekarang
│       │   │   └── response/
│       │   │       ├── AuthResponse.java
│       │   │       ├── QrResponse.java
│       │   │       └── ScanResponse.java
│       │   │
│       │   ├── exception/
│       │   │   ├── GlobalExceptionHandler.java
│       │   │   ├── QrExpiredException.java
│       │   │   ├── QrAlreadyClosedException.java
│       │   │   ├── JadwalNotFoundException.java   ← ⭐ baru
│       │   │   └── UnauthorizedException.java
│       │   │
│       │   └── util/
│       │       ├── JwtUtil.java
│       │       ├── HariUtil.java             ← ⭐ convert DayOfWeek → "Senin", dll
│       │       └── QrCodeGenerator.java
│       │
│       └── resources/
│           ├── application.yml
│           └── db/migration/
│               ├── V1__create_users.sql
│               ├── V2__create_rooms.sql
│               ├── V3__create_mata_kuliahs.sql
│               ├── V4__create_kelas.sql
│               ├── V5__create_jadwals.sql     ← seeder dari data existing
│               ├── V6__create_qr_sessions.sql
│               └── V7__create_transactions.sql
│
├── frontend/
│   └── lib/
│       ├── main.dart
│       │
│       ├── core/
│       │   ├── constants/
│       │   │   ├── api_constants.dart
│       │   │   └── app_constants.dart
│       │   ├── network/
│       │   │   ├── api_client.dart
│       │   │   └── interceptors/
│       │   │       └── auth_interceptor.dart
│       │   ├── storage/
│       │   │   └── secure_storage.dart
│       │   └── utils/
│       │       └── date_formatter.dart
│       │
│       ├── features/
│       │   ├── auth/
│       │   │   ├── data/
│       │   │   │   ├── auth_repository.dart
│       │   │   │   └── auth_remote_datasource.dart
│       │   │   └── presentation/
│       │   │       ├── login_page.dart
│       │   │       └── login_controller.dart
│       │   │
│       │   ├── dashboard/
│       │   │   └── presentation/
│       │   │       ├── dashboard_page.dart
│       │   │       └── dashboard_controller.dart
│       │   │
│       │   ├── scanner/
│       │   │   ├── data/
│       │   │   │   └── scan_repository.dart
│       │   │   └── presentation/
│       │   │       ├── scanner_page.dart         ← scan → langsung kirim, no form
│       │   │       ├── scan_result_page.dart     ← tampilkan hasil AMBIL/KEMBALI
│       │   │       └── scanner_controller.dart
│       │   │
│       │   ├── history/
│       │   │   └── presentation/
│       │   │       ├── history_page.dart
│       │   │       └── history_controller.dart
│       │   │
│       │   └── admin/
│       │       ├── data/
│       │       │   └── qr_repository.dart
│       │       └── presentation/
│       │           ├── admin_dashboard_page.dart
│       │           ├── generate_qr_page.dart
│       │           └── admin_controller.dart
│       │
│       └── shared/
│           ├── widgets/
│           │   ├── app_button.dart
│           │   ├── app_text_field.dart
│           │   └── qr_display_widget.dart
│           └── models/
│               ├── user_model.dart
│               ├── jadwal_model.dart
│               ├── qr_session_model.dart
│               └── transaction_model.dart
│
└── docs/
    ├── CLAUDE.md
    ├── api-spec.md
    └── db-schema.md
```

---

## 🗄️ Skema Database PostgreSQL Lengkap

> Data `jadwals` sudah ada dari sistem existing (MySQL dump).
> Migration di bawah adalah versi PostgreSQL-nya.

### V1 — `users`
```sql
CREATE TABLE users (
    id          BIGSERIAL PRIMARY KEY,
    username    VARCHAR(100) UNIQUE NOT NULL,
    email       VARCHAR(150) UNIQUE NOT NULL,
    password    VARCHAR(255) NOT NULL,            -- BCrypt
    full_name   VARCHAR(200) NOT NULL,
    role        VARCHAR(20)  NOT NULL DEFAULT 'USER', -- USER | ADMIN | DOSEN
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP NOT NULL DEFAULT NOW()
);
```

### V2 — `rooms`
```sql
CREATE TABLE rooms (
    id          BIGSERIAL PRIMARY KEY,
    room_code   VARCHAR(50)  UNIQUE NOT NULL,   -- TIK.101, TIK.102, dst
    room_name   VARCHAR(200) NOT NULL,           -- Lab Telematika, dst
    location    VARCHAR(200),
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);
```

### V3 — `mata_kuliahs`
```sql
CREATE TABLE mata_kuliahs (
    id          BIGSERIAL PRIMARY KEY,
    kode        VARCHAR(50)  UNIQUE NOT NULL,
    nama        VARCHAR(200) NOT NULL,
    sks         INT,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);
```

### V4 — `kelas`
```sql
CREATE TABLE kelas (
    id          BIGSERIAL PRIMARY KEY,
    nama_kelas  VARCHAR(50)  NOT NULL,    -- TI.2A, TRKJ.1B, TRMM.2C, dst
    prodi       VARCHAR(100),
    angkatan    INT,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);
```

### V5 — `jadwals` ← Tabel utama dari data existing
```sql
-- Struktur sesuai dump MySQL yang sudah ada, dikonversi ke PostgreSQL
CREATE TABLE jadwals (
    id              BIGSERIAL PRIMARY KEY,
    mata_kuliah_id  BIGINT NOT NULL REFERENCES mata_kuliahs(id) ON DELETE CASCADE,
    room_id         BIGINT NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    class_id        BIGINT NOT NULL REFERENCES kelas(id) ON DELETE CASCADE,
    dosen_id        BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    hari            VARCHAR(20)  NOT NULL,   -- Senin | Selasa | Rabu | Kamis | Jumat
    tipe_jadwal     VARCHAR(50)  NOT NULL DEFAULT 'rutin', -- rutin | insidental
    jam_mulai       TIME NOT NULL,
    jam_selesai     TIME NOT NULL,
    created_at      TIMESTAMP DEFAULT NOW(),
    updated_at      TIMESTAMP DEFAULT NOW()
);

-- Index kritis untuk performa auto-lookup saat scan QR
CREATE INDEX idx_jadwal_room_hari     ON jadwals(room_id, hari);
CREATE INDEX idx_jadwal_room_hari_jam ON jadwals(room_id, hari, jam_mulai, jam_selesai);
```

### V6 — `qr_sessions`
```sql
CREATE TABLE qr_sessions (
    id            BIGSERIAL PRIMARY KEY,
    token         VARCHAR(255) UNIQUE NOT NULL,   -- token acak UUID
    room_id       BIGINT NOT NULL REFERENCES rooms(id),
    session_date  DATE NOT NULL,
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,
    created_by    BIGINT REFERENCES users(id),
    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    expired_at    TIMESTAMP NOT NULL,

    -- Satu room hanya boleh punya 1 QR aktif per hari
    CONSTRAINT uq_qr_room_date UNIQUE (room_id, session_date)
);

CREATE INDEX idx_qr_token     ON qr_sessions(token);
CREATE INDEX idx_qr_room_date ON qr_sessions(room_id, session_date);
```

### V7 — `transactions`
```sql
CREATE TABLE transactions (
    id              BIGSERIAL PRIMARY KEY,
    qr_session_id   BIGINT NOT NULL REFERENCES qr_sessions(id),
    jadwal_id       BIGINT REFERENCES jadwals(id),  -- hasil auto-lookup, bisa null jika insidental
    user_id         BIGINT NOT NULL REFERENCES users(id),

    -- Data yang di-resolve otomatis dari jadwals saat scan
    -- Disimpan juga sebagai snapshot supaya tidak berubah jika jadwal diubah
    dosen_snapshot      VARCHAR(200),
    mata_kuliah_snapshot VARCHAR(200),
    kelas_snapshot      VARCHAR(50),

    waktu_ambil     TIMESTAMP,
    waktu_kembali   TIMESTAMP,
    status          VARCHAR(20) NOT NULL DEFAULT 'AMBIL',  -- AMBIL | KEMBALI
    keterangan      TEXT,                                  -- jika ada catatan
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),

    -- 1 QR session hanya 1 transaksi aktif
    CONSTRAINT uq_active_transaction UNIQUE (qr_session_id)
);

CREATE INDEX idx_trx_user      ON transactions(user_id);
CREATE INDEX idx_trx_status    ON transactions(status);
CREATE INDEX idx_trx_jadwal    ON transactions(jadwal_id);
```

---

## ⭐ Factory Method — Implementasi Lengkap

### Abstract Creator
```java
// factory/QrSessionCreator.java
package com.kampus.kunciruang.factory;

import com.kampus.kunciruang.model.QrSession;
import com.kampus.kunciruang.model.Room;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

public abstract class QrSessionCreator {

    // Factory Method — wajib diimplementasikan subclass
    public abstract QrSession createSession(Room room, LocalDate date);

    // Template method — dipakai semua subclass
    protected String generateToken() {
        return UUID.randomUUID().toString().replace("-", "");
    }

    // QR expired 1 jam setelah hari berakhir (grace period)
    protected LocalDateTime calculateExpiry(LocalDate date) {
        return date.atTime(23, 59, 59);
    }
}
```

### Concrete Creators
```java
// factory/MorningQrCreator.java
public class MorningQrCreator extends QrSessionCreator {
    @Override
    public QrSession createSession(Room room, LocalDate date) {
        QrSession session = new QrSession();
        session.setToken(generateToken());
        session.setRoom(room);
        session.setSessionDate(date);
        session.setExpiredAt(calculateExpiry(date));
        session.setActive(true);
        return session;
    }
}

// factory/AfternoonQrCreator.java
public class AfternoonQrCreator extends QrSessionCreator {
    @Override
    public QrSession createSession(Room room, LocalDate date) {
        QrSession session = new QrSession();
        session.setToken(generateToken());
        session.setRoom(room);
        session.setSessionDate(date);
        session.setExpiredAt(calculateExpiry(date));
        session.setActive(true);
        return session;
    }
}

// factory/EveningQrCreator.java
public class EveningQrCreator extends QrSessionCreator {
    @Override
    public QrSession createSession(Room room, LocalDate date) {
        QrSession session = new QrSession();
        session.setToken(generateToken());
        session.setRoom(room);
        session.setSessionDate(date);
        session.setExpiredAt(calculateExpiry(date));
        session.setActive(true);
        return session;
    }
}
```

### Factory Dispatcher
```java
// factory/QrCreatorFactory.java
@Component
public class QrCreatorFactory {

    public QrSessionCreator getCreator(String sessionType) {
        return switch (sessionType.toUpperCase()) {
            case "MORNING"   -> new MorningQrCreator();
            case "AFTERNOON" -> new AfternoonQrCreator();
            case "EVENING"   -> new EveningQrCreator();
            default -> throw new IllegalArgumentException(
                "Tipe sesi tidak valid: " + sessionType
            );
        };
    }
}
```

---

## ⭐ Auto-Lookup Jadwal — Inti Perubahan v2.0

### HariUtil (helper convert DayOfWeek ke Bahasa Indonesia)
```java
// util/HariUtil.java
public class HariUtil {

    public static String toIndonesian(DayOfWeek day) {
        return switch (day) {
            case MONDAY    -> "Senin";
            case TUESDAY   -> "Selasa";
            case WEDNESDAY -> "Rabu";
            case THURSDAY  -> "Kamis";
            case FRIDAY    -> "Jumat";
            case SATURDAY  -> "Sabtu";
            case SUNDAY    -> "Minggu";
        };
    }
}
```

### JadwalRepository — Query auto-lookup
```java
// repository/JadwalRepository.java
public interface JadwalRepository extends JpaRepository<Jadwal, Long> {

    /**
     * Query inti: cari jadwal yang cocok dengan room + hari + jam scan
     * Digunakan saat user scan QR
     */
    @Query("""
        SELECT j FROM Jadwal j
        WHERE j.room.id = :roomId
          AND j.hari = :hari
          AND :jamSekarang >= j.jamMulai
          AND :jamSekarang <= j.jamSelesai
        ORDER BY j.jamMulai ASC
    """)
    Optional<Jadwal> findAktifByRoomHariJam(
        @Param("roomId")      Long roomId,
        @Param("hari")        String hari,
        @Param("jamSekarang") LocalTime jamSekarang
    );

    /**
     * Untuk dashboard admin: lihat semua jadwal hari ini per room
     */
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
}
```

### ScanService — Logika lengkap dengan auto-lookup
```java
// service/ScanService.java
@Service
@Transactional
@RequiredArgsConstructor
public class ScanService {

    private final QrSessionRepository   qrSessionRepository;
    private final JadwalRepository      jadwalRepository;
    private final TransactionRepository transactionRepository;

    public ScanResponse processScan(String token, Long userId) {

        // ── 1. Validasi token QR ──────────────────────────────────────
        QrSession session = qrSessionRepository.findByToken(token)
            .orElseThrow(() -> new RuntimeException("QR tidak valid atau tidak ditemukan"));

        if (!session.isActive()) {
            throw new QrExpiredException("QR sudah dinonaktifkan oleh admin");
        }
        if (session.getExpiredAt().isBefore(LocalDateTime.now())) {
            throw new QrExpiredException("QR sudah kadaluarsa");
        }

        // ── 2. Tentukan hari dan jam sekarang ─────────────────────────
        LocalDateTime now       = LocalDateTime.now();
        String        hari      = HariUtil.toIndonesian(now.getDayOfWeek());
        LocalTime     jamScan   = now.toLocalTime();

        // ── 3. Auto-lookup jadwal dari database ───────────────────────
        Optional<Jadwal> jadwalOpt = jadwalRepository.findAktifByRoomHariJam(
            session.getRoom().getId(),
            hari,
            jamScan
        );

        // ── 4. Resolve data jadwal ────────────────────────────────────
        Jadwal jadwal             = jadwalOpt.orElse(null);
        String dosenSnapshot      = jadwal != null ? jadwal.getDosen().getFullName()      : "Tidak ada jadwal";
        String mataKuliahSnapshot = jadwal != null ? jadwal.getMataKuliah().getNama()     : "Tidak ada jadwal";
        String kelasSnapshot      = jadwal != null ? jadwal.getKelas().getNamaKelas()     : "Tidak ada jadwal";

        // ── 5. Cek apakah sudah ada transaksi ─────────────────────────
        Optional<Transaction> existing = transactionRepository
            .findByQrSessionId(session.getId());

        if (existing.isEmpty()) {
            // ── AMBIL ─────────────────────────────────────────────────
            Transaction trx = new Transaction();
            trx.setQrSession(session);
            trx.setJadwal(jadwal);
            trx.setUserId(userId);
            trx.setDosenSnapshot(dosenSnapshot);
            trx.setMataKuliahSnapshot(mataKuliahSnapshot);
            trx.setKelasSnapshot(kelasSnapshot);
            trx.setWaktuAmbil(now);
            trx.setStatus("AMBIL");
            transactionRepository.save(trx);

            return ScanResponse.builder()
                .status("AMBIL")
                .message("Kunci berhasil diambil")
                .transactionId(trx.getId())
                .roomCode(session.getRoom().getRoomCode())
                .roomName(session.getRoom().getRoomName())
                .dosen(dosenSnapshot)
                .mataKuliah(mataKuliahSnapshot)
                .kelas(kelasSnapshot)
                .waktuAmbil(now)
                .build();

        } else {
            Transaction trx = existing.get();

            if ("KEMBALI".equals(trx.getStatus())) {
                throw new QrAlreadyClosedException("Kunci sudah dikembalikan sebelumnya");
            }

            // ── KEMBALI ───────────────────────────────────────────────
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
                .roomCode(session.getRoom().getRoomCode())
                .durasi(durasi)
                .waktuKembali(now)
                .build();
        }
    }
}
```

---

## 🔌 API Endpoints Lengkap

### Auth

| Method | Endpoint           | Deskripsi        | Role |
|--------|--------------------|------------------|------|
| POST   | `/api/auth/login`  | Login, return JWT | ALL |
| POST   | `/api/auth/logout` | Invalidate token  | ALL |

### QR (Admin only)

| Method | Endpoint               | Deskripsi                    | Role  |
|--------|------------------------|------------------------------|-------|
| POST   | `/api/qr/generate`     | Generate QR untuk 1 ruangan  | ADMIN |
| GET    | `/api/qr/list`         | List semua QR aktif          | ADMIN |
| DELETE | `/api/qr/{id}/revoke`  | Nonaktifkan QR               | ADMIN |

### Scan (User & Admin)

| Method | Endpoint    | Deskripsi                        | Role       |
|--------|-------------|----------------------------------|------------|
| POST   | `/api/scan` | Scan QR → auto AMBIL / KEMBALI  | USER/ADMIN |

### Jadwal (Info)

| Method | Endpoint                         | Deskripsi                       | Role  |
|--------|----------------------------------|---------------------------------|-------|
| GET    | `/api/jadwal/room/{roomId}/hari/{hari}` | Lihat jadwal ruangan hari ini | ADMIN |
| GET    | `/api/jadwal/today`              | Semua jadwal hari ini           | ADMIN |

### Transaksi

| Method | Endpoint                 | Deskripsi                  | Role  |
|--------|--------------------------|----------------------------|-------|
| GET    | `/api/transactions`      | Riwayat saya               | USER  |
| GET    | `/api/transactions/all`  | Semua transaksi            | ADMIN |
| GET    | `/api/transactions/{id}` | Detail transaksi           | BOTH  |

---

## 📋 Contoh Request & Response

### POST `/api/auth/login`
```json
// Request
{
  "username": "budi123",
  "password": "secretpass"
}

// Response
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "role": "USER",
  "fullName": "Budi Santoso"
}
```

### POST `/api/qr/generate`
```json
// Request (Authorization: Bearer <admin_token>)
{
  "roomId": 1,
  "sessionType": "MORNING",
  "date": "2026-05-26"
}

// Response
{
  "token": "a3f9c2b1d4e5f678...",
  "roomCode": "TIK.101",
  "roomName": "Lab Telematika",
  "sessionDate": "2026-05-26",
  "expiredAt": "2026-05-26T23:59:59",
  "qrImageBase64": "iVBORw0KGgo..."
}
```

### POST `/api/scan` ← Sangat simpel, hanya kirim token
```json
// Request (Authorization: Bearer <user_token>)
// ⭐ Tidak perlu isi dosen atau mata kuliah — semua otomatis dari jadwals
{
  "token": "a3f9c2b1d4e5f678..."
}

// Response — AMBIL (jadwal ditemukan)
{
  "status": "AMBIL",
  "message": "Kunci berhasil diambil",
  "transactionId": 42,
  "roomCode": "TIK.101",
  "roomName": "Lab Telematika",
  "dosen": "M. Reza Zulman",
  "mataKuliah": "Praktikum Desain Pattern",
  "kelas": "TI.2A",
  "waktuAmbil": "2026-05-26T10:25:00"
}

// Response — AMBIL (tidak ada jadwal di jam ini)
{
  "status": "AMBIL",
  "message": "Kunci berhasil diambil (di luar jadwal)",
  "transactionId": 43,
  "roomCode": "TIK.101",
  "dosen": "Tidak ada jadwal",
  "mataKuliah": "Tidak ada jadwal",
  "kelas": "Tidak ada jadwal",
  "waktuAmbil": "2026-05-26T18:30:00"
}

// Response — KEMBALI
{
  "status": "KEMBALI",
  "message": "Kunci berhasil dikembalikan",
  "transactionId": 42,
  "roomCode": "TIK.101",
  "waktuKembali": "2026-05-26T11:55:00",
  "durasi": "1 jam 30 menit"
}
```

---

## 📱 Flutter — Alur yang Disederhanakan (v2.0)

### Sebelum vs Sesudah

```
❌ v1.0 (ada form manual)          ✅ v2.0 (zero input)
────────────────────────           ────────────────────
1. Login                           1. Login
2. Tap "Scan QR"                   2. Tap "Scan QR"
3. Scan QR                         3. Scan QR
4. Isi dosen (manual)              4. Langsung → Result ✅
5. Isi mata kuliah (manual)
6. Submit
7. Result
```

### Scanner Page (v2.0 — langsung submit setelah scan)
```dart
// features/scanner/presentation/scanner_page.dart

class ScannerPage extends StatelessWidget {

  void _onQrDetected(BuildContext context, String token) async {
    // Langsung kirim ke backend — tidak ada form lagi
    final result = await ScanRepository().scan(token);
    
    // Navigasi ke result page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ScanResultPage(result: result)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan QR Ruangan')),
      body: MobileScanner(
        onDetect: (capture) {
          final barcode = capture.barcodes.first;
          if (barcode.rawValue != null) {
            _onQrDetected(context, barcode.rawValue!);
          }
        },
      ),
    );
  }
}
```

### Scan Result Page
```dart
// features/scanner/presentation/scan_result_page.dart

class ScanResultPage extends StatelessWidget {
  final ScanResponse result;
  const ScanResultPage({required this.result});

  @override
  Widget build(BuildContext context) {
    final isAmbil = result.status == 'AMBIL';

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAmbil ? Icons.lock_open : Icons.lock,
              size: 80,
              color: isAmbil ? Colors.green : Colors.orange,
            ),
            Text(
              isAmbil ? '✅ Kunci Diambil' : '🔒 Kunci Dikembalikan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Data dari auto-lookup jadwal
            _InfoRow('Ruangan',   result.roomCode),
            if (isAmbil) ...[
              _InfoRow('Kelas',      result.kelas),
              _InfoRow('MK',         result.mataKuliah),
              _InfoRow('Dosen',      result.dosen),
              _InfoRow('Jam Ambil',  result.waktuAmbil),
            ] else ...[
              _InfoRow('Durasi',     result.durasi),
              _InfoRow('Jam Kembali', result.waktuKembali),
            ],
          ],
        ),
      ),
    );
  }
}
```

### Secure Storage JWT
```dart
// core/storage/secure_storage.dart
// Gunakan flutter_secure_storage — JANGAN SharedPreferences untuk token

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) =>
      _storage.write(key: 'jwt_token', value: token);

  static Future<String?> getToken() =>
      _storage.read(key: 'jwt_token');

  static Future<void> deleteToken() =>
      _storage.delete(key: 'jwt_token');
}
```

### Auth Interceptor Dio
```dart
// core/network/interceptors/auth_interceptor.dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired → redirect ke login
      await SecureStorage.deleteToken();
      // navigasi ke login
    }
    handler.next(err);
  }
}
```

---

## 📦 Dependencies

### Spring Boot `pom.xml`
```xml
<!-- Web & JPA -->
<dependency>spring-boot-starter-web</dependency>
<dependency>spring-boot-starter-data-jpa</dependency>
<dependency>spring-boot-starter-security</dependency>
<dependency>spring-boot-starter-validation</dependency>

<!-- PostgreSQL -->
<dependency>postgresql</dependency>

<!-- JWT -->
<dependency>io.jsonwebtoken:jjwt-api:0.12.3</dependency>
<dependency>io.jsonwebtoken:jjwt-impl:0.12.3</dependency>
<dependency>io.jsonwebtoken:jjwt-jackson:0.12.3</dependency>

<!-- QR Code -->
<dependency>com.google.zxing:core:3.5.2</dependency>
<dependency>com.google.zxing:javase:3.5.2</dependency>

<!-- Lombok -->
<dependency>lombok</dependency>

<!-- Flyway (DB Migration) -->
<dependency>flyway-core</dependency>
<dependency>flyway-database-postgresql</dependency>
```

### Flutter `pubspec.yaml`
```yaml
dependencies:
  flutter:
    sdk: flutter

  # HTTP Client
  dio: ^5.4.0

  # QR Scanner
  mobile_scanner: ^5.0.0

  # QR Display (untuk admin tampilkan QR)
  qr_flutter: ^4.1.0

  # Secure Storage (WAJIB untuk JWT)
  flutter_secure_storage: ^9.0.0

  # State Management
  get: ^4.6.6

  # Utils
  intl: ^0.19.0
```

---

## ⚙️ application.yml

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/kunci_ruang_db
    username: ${DB_USERNAME:postgres}
    password: ${DB_PASSWORD:postgres}
    driver-class-name: org.postgresql.Driver

  jpa:
    hibernate:
      ddl-auto: validate       # pakai Flyway untuk semua perubahan schema
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true

  flyway:
    enabled: true
    locations: classpath:db/migration

app:
  jwt:
    secret: ${JWT_SECRET:ganti-dengan-secret-minimal-256-bit}
    expiration: 86400000       # 24 jam

server:
  port: 8080
```

---

## 🔄 Diagram Alur Final (v2.0)

```
╔══════════════════════════════════════════════════════════════════╗
║                        ADMIN FLOW                               ║
║                                                                  ║
║  Login → Dashboard Admin                                         ║
║              │                                                   ║
║         Pilih Room + Tanggal + Tipe Sesi                         ║
║              │                                                   ║
║         POST /api/qr/generate                                    ║
║              │                                                   ║
║    QrCreatorFactory.getCreator(sessionType)                      ║
║         ┌────┴──────────────┐                                    ║
║   MorningCreator  AfternoonCreator  EveningCreator               ║
║         └────┬──────────────┘                                    ║
║    createSession() → simpan DB → return QR image                 ║
║              │                                                   ║
║    Admin tempel/share QR di pintu ruangan                        ║
╚══════════════════════════════════════════════════════════════════╝

╔══════════════════════════════════════════════════════════════════╗
║                      USER FLOW (v2.0)                           ║
║                                                                  ║
║  Login → Dashboard                                               ║
║              │                                                   ║
║         Tap "Scan QR"                                            ║
║              │                                                   ║
║         Scan QR (kamera) → dapat token                           ║
║              │                                                   ║
║         POST /api/scan { token }   ← HANYA INI, no form         ║
║              │                                                   ║
║    ScanService.processScan()                                     ║
║         │                                                        ║
║         ├── Validasi QrSession (aktif? expired?)                 ║
║         │                                                        ║
║         ├── ⭐ Auto-lookup jadwals                               ║
║         │      WHERE room_id = X                                 ║
║         │        AND hari = 'Senin'                              ║
║         │        AND jam_sekarang BETWEEN jam_mulai AND jam_selesai
║         │                                                        ║
║         │      → dapat: dosen, mata_kuliah, kelas (otomatis)    ║
║         │                                                        ║
║         ├── Cek transaksi existing?                              ║
║         │      ├── Tidak ada → status = AMBIL → simpan           ║
║         │      └── Ada (AMBIL) → status = KEMBALI → update       ║
║         │                                                        ║
║    Tampilkan Result di Flutter:                                  ║
║    ✅ AMBIL  → Ruang / Kelas / MK / Dosen / Jam Ambil           ║
║    🔒 KEMBALI → Ruang / Durasi / Jam Kembali                    ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## ✅ Checklist Development

### Backend (Spring Boot)
- [ ] Setup project Spring Boot + dependencies
- [ ] Konfigurasi `application.yml` (PostgreSQL)
- [ ] Flyway migration V1–V7
- [ ] Seed data rooms, mata_kuliahs, kelas, users (dosen) dari PDF jadwal
- [ ] Seed data jadwals dari SQL dump (konversi ke PostgreSQL)
- [ ] Implementasi JWT Auth (login, filter, util)
- [ ] `HariUtil` — convert DayOfWeek ke Bahasa Indonesia
- [ ] Factory Method (QrSessionCreator + 3 subclass + dispatcher)
- [ ] `QrService` + `QrController` — generate QR per room
- [ ] `JadwalRepository` — query auto-lookup (room + hari + jam)
- [ ] `ScanService` — proses AMBIL/KEMBALI dengan auto-lookup
- [ ] `ScanController`
- [ ] `TransactionController` — riwayat & detail
- [ ] `GlobalExceptionHandler`
- [ ] Test manual semua endpoint via Postman

### Frontend (Flutter)
- [ ] Setup project + struktur folder fitur
- [ ] Konfigurasi Dio + `AuthInterceptor`
- [ ] `SecureStorage` untuk JWT
- [ ] Login page + simpan token
- [ ] Dashboard page (tombol scan + riwayat)
- [ ] Scanner page (mobile_scanner → langsung POST /api/scan)
- [ ] Scan result page (tampil data dari auto-lookup)
- [ ] History page (riwayat transaksi user)
- [ ] Admin: generate QR page + tampil QR image
- [ ] Handle loading & error state

---

## 🚀 Urutan Pengerjaan yang Disarankan

```
Fase 1 — Persiapan Database
  1. Install PostgreSQL, buat database kunci_ruang_db
  2. Konversi & jalankan migration V1–V5 (termasuk seed data jadwals)
  3. Verifikasi data jadwals benar via psql/DBeaver

Fase 2 — Backend Core
  4. Setup Spring Boot project + Flyway + application.yml
  5. Buat semua Model JPA + Repository
  6. Implementasi JWT (JwtUtil, SecurityConfig, AuthController)
  7. Buat HariUtil

Fase 3 — QR & Scan (Fitur Utama)
  8. Implementasi Factory Method (QrSessionCreator)
  9. QrService + QrCodeGenerator + QrController
  10. JadwalRepository dengan query auto-lookup
  11. ScanService dengan logika AMBIL/KEMBALI + auto-lookup
  12. ScanController
  13. Test via Postman: generate QR → scan → cek transaksi

Fase 4 — Flutter
  14. Setup project + struktur folder
  15. Core: Dio, AuthInterceptor, SecureStorage
  16. Login page
  17. Dashboard + Scanner page (langsung POST setelah scan)
  18. Scan result page
  19. History page
  20. Admin: generate QR page

Fase 5 — Polish
  21. Handle edge cases (QR expired, tidak ada jadwal, double scan)
  22. UI/UX refinement
  23. Testing end-to-end
```

---

## 🔍 Edge Cases yang Harus Ditangani

| Kondisi | Handling |
|---------|----------|
| QR di-scan di luar jam jadwal | Simpan transaksi dengan dosen/MK = "Tidak ada jadwal" |
| QR expired (hari berbeda) | Return error 400 + pesan jelas |
| QR sudah KEMBALI, di-scan lagi | Return error 409 "Transaksi sudah selesai" |
| 2 user scan QR yang sama bersamaan | DB constraint `UNIQUE (qr_session_id)` menangani race condition |
| Jadwal overlap (2 jadwal di jam sama) | Query return `ORDER BY jam_mulai ASC LIMIT 1` — ambil yang lebih awal |
| Admin generate QR untuk room yang sudah ada QR hari ini | DB constraint `UNIQUE (room_id, session_date)` mencegah duplikat |

---

*Generated for: Sistem Peminjaman Kunci Ruang Kampus — Jurusan TIK*
*Stack: Flutter • Spring Boot • PostgreSQL*
*Pattern: Factory Method (QR Session Creator)*
*Versi: 2.0 — Zero Manual Input, Auto-Lookup dari Database Jadwal*
