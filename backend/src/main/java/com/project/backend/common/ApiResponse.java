package com.project.backend.common;

import lombok.Getter;
import java.util.HashMap;
import java.util.Map;

@Getter
public class ApiResponse<T> {

  private final ApiResponseHeader header;
  private Map<String, T> body;
  private T dto;

  public ApiResponse(ApiResponseHeader apiResponseHeader, Object o) {
    this.header = apiResponseHeader;
    this.dto = (T) o;
  }

  public ApiResponse(ApiResponseHeader apiResponseHeader, String name, T body) {
    Map<String, T> map = new HashMap<>();
    map.put(name, body);

    this.header = apiResponseHeader;
    this.body = map;
  }


  public static <T> ApiResponse<T> success() {
    return new ApiResponse<>(new ApiResponseHeader(ResponseType.SUCCESS), null);
  }

  public static <T> ApiResponse<T> success(T dto) {
    return new ApiResponse<>(new ApiResponseHeader(ResponseType.SUCCESS), dto);
  }

  // 바디를 담은 성공 응답
  public static <T> ApiResponse<T> success(String name, T body) {
    return new ApiResponse<>(new ApiResponseHeader(ResponseType.SUCCESS), name, body);
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

  // 클라이밍장 조회시 일치 내역 없음
  public static <T> ApiResponse<T> notMatchedClimbGround() {
    return new ApiResponse<>(new ApiResponseHeader(ResponseType.NO_MATCHING_CLIMBING_GYM),null);
  }

  public static <T> ApiResponse<T> notFound() {
    return new ApiResponse<>(new ApiResponseHeader(ResponseType.NOT_FOUND_404),null);
  }
}
