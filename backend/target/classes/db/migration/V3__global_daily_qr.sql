-- V8: Ubah QR Sessions agar bisa global (tanpa room_id)
-- Hapus constraint FK dan NOT NULL dari room_id
ALTER TABLE qr_sessions
    DROP FOREIGN KEY fk_qr_room;

ALTER TABLE qr_sessions
    DROP INDEX uq_qr_room_date;

ALTER TABLE qr_sessions
    MODIFY COLUMN room_id BIGINT UNSIGNED NULL;

-- Tambah unique constraint per tanggal saja (1 QR per hari, global)
ALTER TABLE qr_sessions
    ADD CONSTRAINT uq_qr_session_date UNIQUE (session_date);
