package com.kampus.kunciruang.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ScanRequest {
    @NotBlank(message = "Token QR tidak boleh kosong")
    private String token;

    private Boolean withInfokus = false;
}
