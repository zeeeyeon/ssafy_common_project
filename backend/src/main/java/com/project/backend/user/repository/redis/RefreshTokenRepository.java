package com.project.backend.user.repository.redis;

import com.project.backend.user.entity.RefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RefreshTokenRepository extends JpaRepository<RefreshToken, Long> {
  Optional<RefreshToken> findByUserId(Long userId);
  Optional<RefreshToken> findByToken(String token);
}
