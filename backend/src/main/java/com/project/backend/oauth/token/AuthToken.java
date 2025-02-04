package com.project.backend.oauth.token;

import com.project.backend.user.entity.UserProviderEnum;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import java.security.Key;
import java.util.Base64;
import java.util.Date;

@Slf4j
public class AuthToken {

  @Getter
  private final String token;
  private final Key key;

  static final String AUTHORITIES_KEY = "role";
  private static final String PROVIDER_TYPE_KEY = "provider";

  // 생성자: 기존 토큰과 비밀키를 받아 초기화
  public AuthToken(String token, String secretKeyString) {
    this.token = token;
    this.key = getKeyFromString(secretKeyString);
  }

  // 생성자: ID와 만료 시간, 비밀키로 토큰 생성
  public AuthToken(String id, Date expiry, String secretKeyString) {
    this.key = getKeyFromString(secretKeyString);
    this.token = createAuthToken(id, expiry);
  }

  // 생성자: ID, 역할(role), 만료 시간, 비밀키로 토큰 생성
  public AuthToken(String id, String role, Date expiry, String secretKeyString) {
    this.key = getKeyFromString(secretKeyString);
    this.token = createAuthToken(id, role, expiry);
  }

  // 생성자: ID, 사용자 정보(UserInfo), 만료 시간, 비밀키로 토큰 생성
  public AuthToken(String id, UserInfo userInfo, Date expiry, String secretKeyString) {
    this.key = getKeyFromString(secretKeyString);
    this.token = createAuthToken(id, userInfo, expiry);
  }

  // String 형태의 비밀키를 Key 객체로 변환
  private Key getKeyFromString(String secretKeyString) {
    try {
      byte[] keyBytes = Base64.getDecoder().decode(secretKeyString);
      if (keyBytes.length < 64) {
        throw new IllegalArgumentException("HS512 알고리즘을 위한 키 길이가 충분하지 않습니다. 키는 최소 512비트(64바이트) 이상이어야 합니다.");
      }
      return Keys.hmacShaKeyFor(keyBytes);
    } catch (IllegalArgumentException e) {
      log.error("비밀키(Base64) 디코딩 실패 또는 키 길이 부족: 비밀키 형식을 확인하세요.", e);
      throw new RuntimeException("비밀키 디코딩 실패 또는 키 길이 부족: Base64 형식을 확인하세요.");
    }
  }

  // 기본 토큰 생성 (ID, 만료 시간)
  private String createAuthToken(String id, Date expiry) {
    return Jwts.builder()
            .setSubject(id)
            .signWith(key, SignatureAlgorithm.HS512)
            .setExpiration(expiry)
            .compact();
  }

  // 역할(role)을 포함한 토큰 생성
  private String createAuthToken(String id, String role, Date expiry) {
    return Jwts.builder()
            .setSubject(id)
            .claim(AUTHORITIES_KEY, role)
            .signWith(key, SignatureAlgorithm.HS512)
            .setExpiration(expiry)
            .compact();
  }

  // 사용자 정보를 포함한 토큰 생성
  private String createAuthToken(String id, UserInfo userInfo, Date expiry) {
    return Jwts.builder()
            .setSubject(id)
            .claim(AUTHORITIES_KEY, userInfo.getRole())
            .claim(PROVIDER_TYPE_KEY, userInfo.getProviderType().toString())
            .claim("username", userInfo.getUsername())
            .claim("email", userInfo.getEmail())
            .claim("email_verified", userInfo.getEmailVerifiedYn())
            .claim("profile_image", userInfo.getProfileImageUrl())
            .signWith(key, SignatureAlgorithm.HS512)
            .setExpiration(expiry)
            .compact();
  }

  // 토큰 유효성 검사
  public boolean validate() {
    return this.getTokenClaims() != null;
  }

  // 토큰에서 클레임(Claims) 추출
  public Claims getTokenClaims() {
    try {
      return Jwts.parserBuilder()
              .setSigningKey(key)
              .build()
              .parseClaimsJws(token)
              .getBody();
    } catch (JwtException e) {
      log.info("Invalid JWT token: {}", e.getMessage());
    }
    return null;
  }

  // 만료된 토큰에서 클레임 추출
  public Claims getExpiredTokenClaims() {
    try {
      Jwts.parserBuilder()
              .setSigningKey(key)
              .build()
              .parseClaimsJws(token)
              .getBody();
    } catch (ExpiredJwtException e) {
      log.info("Expired JWT token.");
      return e.getClaims();
    }
    return null;
  }

  // UserInfo DTO 클래스
  @Getter
  @AllArgsConstructor
  public static class UserInfo {
    private String username;
    private String email;
    private String emailVerifiedYn;
    private String profileImageUrl;
    private UserProviderEnum providerType;
    private String role;
  }
}

