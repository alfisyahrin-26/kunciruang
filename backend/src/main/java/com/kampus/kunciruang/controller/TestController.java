package com.kampus.kunciruang.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

@RestController
public class TestController {
    @GetMapping("/api/auth/test")
    public String test() {
        return new BCryptPasswordEncoder().encode("password");
    }
}
