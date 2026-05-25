CREATE TABLE transactions (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    qr_session_id   BIGINT NOT NULL,
    jadwal_id       BIGINT,
    user_id         BIGINT NOT NULL,
    dosen_snapshot      VARCHAR(200),
    mata_kuliah_snapshot VARCHAR(200),
    kelas_snapshot      VARCHAR(50),
    waktu_ambil     DATETIME,
    waktu_kembali   DATETIME,
    status          VARCHAR(20) NOT NULL DEFAULT 'AMBIL',
    with_infokus    BOOLEAN NOT NULL DEFAULT FALSE,
    keterangan      TEXT,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_trx_qr FOREIGN KEY (qr_session_id) REFERENCES qr_sessions(id),
    CONSTRAINT fk_trx_jadwal FOREIGN KEY (jadwal_id) REFERENCES jadwals(id),
    CONSTRAINT fk_trx_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX idx_trx_user      ON transactions(user_id);
CREATE INDEX idx_trx_status    ON transactions(status);
CREATE INDEX idx_trx_jadwal    ON transactions(jadwal_id);
