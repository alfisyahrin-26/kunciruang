package com.kampus.kunciruang.controller;

import com.kampus.kunciruang.config.CustomUserDetails;
import com.kampus.kunciruang.dto.request.ScanRequest;
import com.kampus.kunciruang.dto.response.ScanResponse;
import com.kampus.kunciruang.service.ScanService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/scan")
@RequiredArgsConstructor
public class ScanController {

    private final ScanService scanService;

    @PostMapping
    public ResponseEntity<ScanResponse> processScan(@Valid @RequestBody ScanRequest request) {
        CustomUserDetails userDetails = (CustomUserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        Long userId = userDetails.getUser().getId();
        return ResponseEntity.ok(scanService.processScan(request.getToken(), userId, request.getWithInfokus()));
    }
}
