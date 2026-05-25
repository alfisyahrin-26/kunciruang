package com.kampus.kunciruang.controller;

import com.kampus.kunciruang.dto.request.LoginRequest;
import com.kampus.kunciruang.dto.response.AuthResponse;
import com.kampus.kunciruang.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PostMapping("/logout")
    public ResponseEntity<String> logout() {
        // In stateless JWT, logout is usually handled on the client side by removing the token.
        // For extra security, we could implement a token blacklist here.
        return ResponseEntity.ok("Logout successful");
    }
}
