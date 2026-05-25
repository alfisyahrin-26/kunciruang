package com.kampus.kunciruang.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.kampus.kunciruang.model.Transaction;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
public class TransactionResponse {
    private Long id;
    private Long userId;
    private String status;
    private String dosenSnapshot;
    private String mataKuliahSnapshot;
    private String kelasSnapshot;
    private Boolean withInfokus;
    private LocalDateTime waktuAmbil;
    private LocalDateTime waktuKembali;
    private LocalDateTime createdAt;

    // QR session info (flat — no nested entity)
    private Long qrSessionId;
    private String qrSessionDate;   // session_date as string
    private String roomCode;        // null jika QR global
    private String roomName;        // null jika QR global

    public static TransactionResponse from(Transaction trx) {
        String roomCode = null;
        String roomName = null;
        String sessionDate = null;

        if (trx.getQrSession() != null) {
            if (trx.getQrSession().getRoom() != null) {
                roomCode = trx.getQrSession().getRoom().getNamaRuang();
                roomName = trx.getQrSession().getRoom().getNamaRuang();
            } else {
                roomCode = "-";
                roomName = "Semua Ruangan";
            }
            if (trx.getQrSession().getSessionDate() != null) {
                sessionDate = trx.getQrSession().getSessionDate().toString();
            }
        }

        return TransactionResponse.builder()
                .id(trx.getId())
                .userId(trx.getUserId())
                .status(trx.getStatus())
                .dosenSnapshot(trx.getDosenSnapshot())
                .mataKuliahSnapshot(trx.getMataKuliahSnapshot())
                .kelasSnapshot(trx.getKelasSnapshot())
                .withInfokus(trx.getWithInfokus())
                .waktuAmbil(trx.getWaktuAmbil())
                .waktuKembali(trx.getWaktuKembali())
                .createdAt(trx.getCreatedAt())
                .qrSessionId(trx.getQrSession() != null ? trx.getQrSession().getId() : null)
                .qrSessionDate(sessionDate)
                .roomCode(roomCode)
                .roomName(roomName)
                .build();
    }
}
