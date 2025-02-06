package com.project.backend.user.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class KakaoLoginResponseDto {
  private String accessToken;
  private String refreshToken;
}
