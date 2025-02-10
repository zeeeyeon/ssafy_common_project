package com.project.backend.user.service;

import com.project.backend.user.entity.RefreshToken;
import com.project.backend.user.repository.redis.RefreshTokenRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RefreshTokenService {

  private final RefreshTokenRepository refreshTokenRepository;

  // 저장 또는 갱신
  public RefreshToken saveRefreshToken(Long userId, String token) {
    RefreshToken refreshToken = refreshTokenRepository.findByUserId(userId)
            .orElse(RefreshToken.builder().userId(userId).build());
    refreshToken.setToken(token);
    return refreshTokenRepository.save(refreshToken);
  }
}
