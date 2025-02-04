package com.project.backend.oauth.token;

import com.project.backend.oauth.exception.TokenValidFailedException;
import com.project.backend.user.entity.User;
import com.project.backend.user.entity.UserProviderEnum;
import com.project.backend.user.entity.UserRoleEnum;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.security.Keys;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Collection;
import java.util.Date;
import java.util.stream.Collectors;

import static com.project.backend.oauth.token.AuthToken.*;

@Component
@Getter
public class AuthTokenProvider {

  private final String secretKey;

  // application.properties에서 jwt.secret 값을 주입
  public AuthTokenProvider(@Value("${jwt.secret}") String secretKey) {
    this.secretKey = secretKey;
  }

  // ID와 만료 시간으로 토큰 생성
  public AuthToken createAuthToken(String id, Date expiry) {
    return new AuthToken(id, expiry, secretKey);
  }

  // ID, 역할(role), 만료 시간으로 토큰 생성
  public AuthToken createAuthToken(String id, String role, Date expiry) {
    return new AuthToken(id, role, expiry, secretKey);
  }

  // ID, 사용자 정보(UserInfo), 만료 시간으로 토큰 생성
  public AuthToken createAuthToken(String id, AuthToken.UserInfo userInfo, Date expiry) {
    return new AuthToken(id, userInfo, expiry, secretKey);
  }

  public AuthToken convertAuthToken(String token) {
    return new AuthToken(token, secretKey);
  }

  // 토큰에서 클레임 추출
  public Claims getTokenClaims(String token) {
    AuthToken authToken = new AuthToken(token, secretKey);
    return authToken.getTokenClaims();
  }

  // 토큰 유효성 검사
  public boolean validateToken(String token) {
    AuthToken authToken = new AuthToken(token, secretKey);
    return authToken.validate();
  }

  public Authentication getAuthentication(AuthToken authToken) {

    if(authToken.validate()) {

      Claims claims = authToken.getTokenClaims();
      Collection<? extends GrantedAuthority> authorities = Arrays.stream(new String[]{claims.get(AUTHORITIES_KEY).toString()})
              .map(SimpleGrantedAuthority::new)
              .collect(Collectors.toList());

//      log.debug("claims subject := [{}]", claims.getSubject());

      User principal = User.builder()
              .username(claims.getSubject())
              .nickname("Unknown")
              .email("NO_EMAIL")
              .emailVerifiedYn("N")
              .profileImageUrl("")
              .providerType(UserProviderEnum.GOOGLE)
              .roleType(UserRoleEnum.USER)
              .createDate(LocalDateTime.now())
              .updateDate(LocalDateTime.now())
              .build();

      return new UsernamePasswordAuthenticationToken(principal, authToken, authorities);
    } else {
      throw new TokenValidFailedException();
    }
  }
}

