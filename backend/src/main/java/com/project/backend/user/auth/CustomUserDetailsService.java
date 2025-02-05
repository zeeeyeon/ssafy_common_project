package com.project.backend.user.auth;

import com.project.backend.user.entity.User;
import com.project.backend.user.repository.jpa.UserRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;
    private final Logger log = LoggerFactory.getLogger(getClass());

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        log.debug("로그인 시도한 username: {}", email);

        User user = userRepository.findByEmail(email)
                .orElseThrow(() ->
                        new UsernameNotFoundException("유저를 찾을 수 없습니다"));

        log.debug("로그인 성공한 user: {}", user.getEmail());

        return new CustomUserDetails(user);
    }
}
