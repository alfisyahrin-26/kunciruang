CREATE TABLE qr_sessions (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    token         VARCHAR(255) UNIQUE NOT NULL,
    room_id       BIGINT,
    session_date  DATE NOT NULL,
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,
    created_by    BIGINT,
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expired_at    TIMESTAMP NOT NULL,
    CONSTRAINT uq_qr_room_date UNIQUE (room_id, session_date),
    CONSTRAINT fk_qr_room FOREIGN KEY (room_id) REFERENCES rooms(id),
    CONSTRAINT fk_qr_creator FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE INDEX idx_qr_token     ON qr_sessions(token);
CREATE INDEX idx_qr_room_date ON qr_sessions(room_id, session_date);
