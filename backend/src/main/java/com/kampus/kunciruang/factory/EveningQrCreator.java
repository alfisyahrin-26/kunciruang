package com.kampus.kunciruang.factory;

import com.kampus.kunciruang.model.QrSession;
import com.kampus.kunciruang.model.Room;

import java.time.LocalDate;

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
