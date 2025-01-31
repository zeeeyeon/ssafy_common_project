package com.project.backend.common;


import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class ApiResponseHeader {
  private final ResponseType responseType; // enum 전체를 보관

  public int getHttpStatus() {
    return responseType.getHttpStatus();
  }

  public String getCode() {
    return responseType.getCode();
  }

  public String getMessage() {
    return responseType.getMessage();
  }
}

