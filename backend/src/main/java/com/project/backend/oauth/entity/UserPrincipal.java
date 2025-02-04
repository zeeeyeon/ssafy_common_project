package com.project.backend.oauth.entity;

import com.project.backend.user.entity.User;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.oauth2.core.oidc.OidcIdToken;
import org.springframework.security.oauth2.core.oidc.OidcUserInfo;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.security.oauth2.core.user.OAuth2User;

import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map;

@Getter
@Setter
public class UserPrincipal implements OAuth2User, UserDetails, OidcUser {

  private final User user;
  private Map<String, Object> attributes;

  // 1) User만 받는 생성자
  public UserPrincipal(User user) {
    this.user = user;
  }

  // 2) User + attributes를 모두 받는 생성자
  public UserPrincipal(User user, Map<String, Object> attributes) {
    this.user = user;
    this.attributes = attributes;
  }

  @Override
  public Map<String, Object> getAttributes() {
    return attributes;
  }

  @Override
  public Collection<? extends GrantedAuthority> getAuthorities() {
    return List.of(new SimpleGrantedAuthority("ROLE_" + user.getRoleType()));
  }

  @Override
  public String getName() {
    return user.getId().toString();
  }

  @Override
  public String getUsername() {
    return user.getUsername();
  }

  @Override
  public String getPassword() {
    return user.getPassword();
  }

  @Override
  public boolean isAccountNonExpired() {
    return true;
  }

  @Override
  public boolean isAccountNonLocked() {
    return true;
  }

  @Override
  public boolean isCredentialsNonExpired() {
    return true;
  }

  @Override
  public boolean isEnabled() {
    return true;
  }

  @Override
  public Map<String, Object> getClaims() {
    return Map.of();
  }

  @Override
  public OidcUserInfo getUserInfo() {
    return null;
  }

  @Override
  public OidcIdToken getIdToken() {
    return null;
  }

  public String getEmail() {
    return user.getEmail();
  }

  public static UserPrincipal create(User user) {
    // 빈 Map 대신 Collections.emptyMap() 사용 (JDK 8 호환성)
    return new UserPrincipal(user, Collections.emptyMap());
  }

  public static UserPrincipal create(User user, Map<String, Object> attributes) {
    if (attributes.containsKey("email") && user.getEmail() == null) {
      user.setEmail((String) attributes.get("email"));
    }
    return new UserPrincipal(user, attributes);
  }
}


