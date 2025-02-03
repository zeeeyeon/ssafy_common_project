package com.project.backend.common.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
@AllArgsConstructor
public enum ResponseCode {

    SUCCESS_LOGIN(successCode(), HttpStatus.OK, "로그인이 성공적으로 완료되었습니다."),
    SUCCESS_SIGNUP(successCode(), HttpStatus.OK, "회원가입이 성공적으로 완료되었습니다."),

    GET_CLIMB_GROUND_DETAIL(successCode(), HttpStatus.OK, "해당 클라이밍장의 정보가 조회되었습니다. "),

    BINDING_ERROR(2000, HttpStatus.BAD_REQUEST, "입력값 중 검증에 실패한 값이 있습니다."),
    BAD_REQUEST(2001, HttpStatus.BAD_REQUEST, "올바르지 않은 요청입니다."),
    ENTITY_NOT_FOUND(404, HttpStatus.NOT_FOUND, "요청하신 데이터를 찾을 수 없습니다."),

    NOT_FOUND_CLIMB_GROUND_DETAIL(404, HttpStatus.NOT_FOUND, "해당 클라이밍장의 정보를 찾을 수 없습니다.");



    private int code;
    private HttpStatus httpStatus;
    private String message;

    private static int successCode() {
        return 200;
    }
}
