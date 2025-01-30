package com.project.backend.oauth.token;

import com.project.backend.oauth.exception.TokenValidFailedException;
import com.project.backend.user.entity.User;
import com.project.backend.user.entity.UserProviderEnum;
import com.project.backend.user.entity.UserRoleEnum;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.security.Key;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Collection;
import java.util.Date;
import java.util.stream.Collectors;

@Slf4j
public class AuthTokenProvider {

  private final Key key;
  private static final String AUTHORITIES_KEY = "role";

  public AuthTokenProvider(String secret) {
    this.key = Keys.hmacShaKeyFor(secret.getBytes());
  }

  public AuthToken createAuthToken(String id, Date expiry) {
    return new AuthToken(id, expiry, key);
  }

  public AuthToken createAuthToken(String id, String role, Date expiry) {
    return new AuthToken(id, role, expiry, key);
  }

  public AuthToken convertAuthToken(String token) {
    return new AuthToken(token, key);
  }

  public Authentication getAuthentication(AuthToken authToken) {

    if(authToken.validate()) {

      Claims claims = authToken.getTokenClaims();
      Collection<? extends GrantedAuthority> authorities = Arrays.stream(new String[]{claims.get(AUTHORITIES_KEY).toString()})
              .map(SimpleGrantedAuthority::new)
              .collect(Collectors.toList());

      log.debug("claims subject := [{}]", claims.getSubject());

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
