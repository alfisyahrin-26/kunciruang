package com.kampus.kunciruang.factory;

import com.kampus.kunciruang.model.QrSession;
import com.kampus.kunciruang.model.Room;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

public abstract class QrSessionCreator {

    // Factory Method
    public abstract QrSession createSession(Room room, LocalDate date);

    // Template method
    protected String generateToken() {
        return UUID.randomUUID().toString().replace("-", "");
    }

    // Default: QR expired at end of the day
    protected LocalDateTime calculateExpiry(LocalDate date) {
        return date.atTime(23, 59, 59);
    }
}
