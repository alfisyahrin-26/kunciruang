package com.kampus.kunciruang.dto.response;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
public class QrResponse {
    private String token;
    private String roomCode;
    private String roomName;
    private LocalDate sessionDate;
    private LocalDateTime expiredAt;
    private String qrImageBase64;
}
