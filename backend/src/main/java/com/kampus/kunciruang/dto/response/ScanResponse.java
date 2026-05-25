package com.kampus.kunciruang.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ScanResponse {
    private String status; // AMBIL / KEMBALI
    private String message;
    private Long transactionId;
    private String roomCode;
    private String roomName;
    private String dosen;
    private String mataKuliah;
    private String kelas;
    private Boolean withInfokus;
    private LocalDateTime waktuAmbil;
    private LocalDateTime waktuKembali;
    private String durasi;
}
