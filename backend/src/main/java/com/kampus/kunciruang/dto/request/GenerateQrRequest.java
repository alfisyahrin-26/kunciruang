package com.kampus.kunciruang.dto.request;

import lombok.Data;

@Data
public class GenerateQrRequest {
    private String date; // format: yyyy-MM-dd, null = hari ini
}
