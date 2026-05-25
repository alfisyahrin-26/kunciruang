package com.kampus.kunciruang;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;
import com.kampus.kunciruang.repository.UserRepository;

import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class KunciRuangApplication {

	public static void main(String[] args) {
		SpringApplication.run(KunciRuangApplication.class, args);
	}

	@Bean
	CommandLineRunner fixPasswords(UserRepository userRepository, PasswordEncoder passwordEncoder) {
		return args -> {
			userRepository.findAll().forEach(user -> {
				user.setPassword(passwordEncoder.encode("password123"));
				userRepository.save(user);
			});
		};
	}
}
