package com.kampus.kunciruang.config;

import com.kampus.kunciruang.model.User;
import com.kampus.kunciruang.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;
    private final com.kampus.kunciruang.repository.MahasiswaRepository mahasiswaRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // username disini sebenarnya adalah email yang dikirim dari frontend
        User user = userRepository.findByEmail(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + username));
        
        String role = mahasiswaRepository.findByUserId(user.getId()).isPresent() ? "MAHASISWA" : "ADMIN";
        
        return new CustomUserDetails(user, role);
    }
}
