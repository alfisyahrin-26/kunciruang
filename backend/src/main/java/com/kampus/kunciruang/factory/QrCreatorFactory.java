package com.kampus.kunciruang.factory;

import org.springframework.stereotype.Component;

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
