package com.project.backend.common;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

import java.util.HashMap;
import java.util.Map;

@Getter
@RequiredArgsConstructor
public class ApiResponse<T> {

  private final ApiResponseHeader header;
  private final Map<String, T> body;


  public static <T> ApiResponse<T> success() {
    return new ApiResponse<>(new ApiResponseHeader(ResponseType.SUCCESS), null);
  }

  // 바디를 담은 성공 응답
  public static <T> ApiResponse<T> success(String name, T body) {
    Map<String, T> map = new HashMap<>();
    map.put(name, body);
    return new ApiResponse<>(new ApiResponseHeader(ResponseType.SUCCESS), map);
  }

  // 실패 응답
  public static <T> ApiResponse<T> fail() {
    return new ApiResponse<>(new ApiResponseHeader(ResponseType.FAILED), null);
  }

  // 그 외 각종 상황별 예시
  public static <T> ApiResponse<T> invalidAccessToken() {
    return new ApiResponse<>(new ApiResponseHeader(ResponseType.INVALID_ACCESS_TOKEN), null);
  }

  public static <T> ApiResponse<T> invalidRefreshToken() {
    return new ApiResponse<>(new ApiResponseHeader(ResponseType.INVALID_REFRESH_TOKEN), null);
  }

  public static <T> ApiResponse<T> notExpiredTokenYet() {
    return new ApiResponse<>(new ApiResponseHeader(ResponseType.NOT_EXPIRED_TOKEN_YET), null);
  }
}
