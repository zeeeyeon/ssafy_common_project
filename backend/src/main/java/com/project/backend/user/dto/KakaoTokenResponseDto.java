package com.project.backend.user.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class KakaoTokenResponseDto {
  @JsonProperty("access_token")
  private String accessToken;
  @JsonProperty("refresh_token")
  private String refreshToken;
  @JsonProperty("expires_in")
  private Long expiresIn;
  @JsonProperty("account_email")
  private String accountEmail;
  @JsonProperty("profile_nickname")
  private String accountNickname;
}
