package com.project.backend.common;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum ResponseType {

  // 예시: 기존 ApiResponse에 있던 것들
  SUCCESS(200, "SU", "Success"),
  NOT_FOUND(400, "NF", "Not Found"),
  FAILED(500, "FA", "서버에서 오류가 발생했습니다."),
  INVALID_ACCESS_TOKEN(401, "IAT", "Invalid access token."),
  INVALID_REFRESH_TOKEN(401, "IRT", "Invalid refresh token."),
  NOT_EXPIRED_TOKEN_YET(400, "NETY", "Not expired token yet."),

  // 예시: 기존 ResponseCode / ResponseMessage에 있던 것들
  EXISTED_USER_EMAIL(400, "EUE", "Existed User Email"),
  NO_EXISTED_USER_EMAIL(200, "NEUE", "No Existed User Email"),
  EXISTED_USER_NICKNAME(400, "EUN", "Existed User Nickname"),
  NO_EXISTED_USER_NICKNAME(200, "NEUN", "No Existed User Nickname"),
  EXISTED_USER_PHONE(200, "EUP", "Existed User Phone"),


  NO_MATCHING_CLIMBING_GYM(204, "NMCG", "No matching climbing gym found."),
  NOT_FOUND_404(404, "NF", "Not Found"),
  CREATED(201,"CR","Row Created successfully"),
  CREATION_FAILED_BAD_REQUEST(400, "CFBR", "Bad request, invalid data provided for creation."),
  DATA_ALREADY_EXISTS(409, "DAE", "Data already exists."),

  NOT_EXIST_DATE(404, "NOT_EXIST_DATE", "해당 날짜의 값이 존재하지 않습니다");


  private final int httpStatus;  // HTTP 상태 코드 혹은 기타 숫자 코드
  private final String code;     // 비즈니스 로직에서 쓸 고유 식별 코드 (ex: "SU", "EUE")
  private final String message;  // 실제 프론트 또는 로그 등에 노출할 메시지
}
