package com.project.backend.user.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class KakaoUserInfoDto {
  private Long id;

  @JsonProperty("kakao_account")
  private KakaoAccount kakaoAccount;

  @Data
  public static class KakaoAccount {
    @JsonProperty("email")
    private String email;

    @JsonProperty("profile")
    private Profile profile;

    @Data
    public static class Profile {
      @JsonProperty("nickname")
      private String nickname;
    }
  }
}
