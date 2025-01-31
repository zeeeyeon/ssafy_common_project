package com.project.backend.oauth.token;

import com.project.backend.user.entity.UserProviderEnum;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import java.security.Key;
import java.util.Date;

@Slf4j
public class AuthToken {

  @Getter
  private final String token;
  private final Key key;

  private static final String AUTHORITIES_KEY = "role";
  private static final String PROVIDER_TYPE_KEY = "provider";

  public AuthToken(String token, Key key) {
      this.token = token;
      this.key = Keys.secretKeyFor(SignatureAlgorithm.HS512);
  }

  AuthToken(String id, Date expiry, Key key) {
    this.key = key;
    this.token = createAuthToken(id, expiry);
  }

  AuthToken(String id, String role, Date expiry, Key key) {
    this.key = key;
    this.token = createAuthToken(id, role, expiry);
  }

  AuthToken(String id, UserInfo userInfo, Date expiry, Key key) {
    this.key = key;
    this.token = createAuthToken(id, userInfo, expiry);
  }

  private String createAuthToken(String id, Date expiry) {
    return Jwts.builder()
            .setSubject(id)
            .signWith(key, SignatureAlgorithm.HS512)
            .setExpiration(expiry)
            .compact();
  }

  private String createAuthToken(String id, String role, Date expiry) {
    return Jwts.builder()
            .setSubject(id)
            .claim(AUTHORITIES_KEY, role)
            .signWith(key, SignatureAlgorithm.HS512)
            .setExpiration(expiry)
            .compact();
  }

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

  // UserInfo DTO 클래스 추가
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

  public boolean validate() {
    return this.getTokenClaims() != null;
  }

  public Claims getTokenClaims() {
    try {
      return Jwts.parserBuilder()
              .setSigningKey(key)
              .build()
              .parseClaimsJws(token)
              .getBody();
    } catch (SecurityException e) {
      log.info("Invalid JWT signature.");
    } catch (MalformedJwtException e) {
      log.info("Invalid JWT toekn.");
    } catch (ExpiredJwtException e) {
      log.info("Expired JWT token.");
    } catch (UnsupportedJwtException e) {
      log.info("Unsupported JWT token.");
    } catch (IllegalArgumentException e) {
      log.info("JWT token compact of handler are invalid.");
    }
    return null;
  }

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

}
