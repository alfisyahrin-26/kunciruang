package com.kampus.kunciruang.service;

import com.kampus.kunciruang.config.CustomUserDetails;
import com.kampus.kunciruang.dto.request.LoginRequest;
import com.kampus.kunciruang.dto.response.AuthResponse;
import com.kampus.kunciruang.model.User;
import com.kampus.kunciruang.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;
    private final com.kampus.kunciruang.repository.MahasiswaRepository mahasiswaRepository;

    public AuthResponse login(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
        );

        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        User user = userDetails.getUser();

        String jwt = jwtUtil.generateToken(userDetails);

        // Tentukan Role (jika ada di tabel mahasiswas berarti MAHASISWA, selain itu ADMIN)
        String role = mahasiswaRepository.findByUserId(user.getId()).isPresent() ? "MAHASISWA" : "ADMIN";

        return AuthResponse.builder()
                .token(jwt)
                .role(role)
                .fullName(user.getFullName())
                .build();
    }
}
