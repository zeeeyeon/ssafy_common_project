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
    GET_CLIMB_GROUND_List(successCode(), HttpStatus.OK, "해당 클라이밍장 리스트 정보가 조회되었습니다. "),

    BINDING_ERROR(2000, HttpStatus.BAD_REQUEST, "입력값 중 검증에 실패한 값이 있습니다."),
    BAD_REQUEST(2001, HttpStatus.BAD_REQUEST, "올바르지 않은 요청입니다."),
    ENTITY_NOT_FOUND(404, HttpStatus.NOT_FOUND, "요청하신 데이터를 찾을 수 없습니다."),

    NO_MATCHING_CLIMBING_GYM(204, HttpStatus.NOT_FOUND, "검색내용과 일치하는 클라이밍장을 찾을 수 없습니다."),
    NOT_FOUND_CLIMB_GROUND(404, HttpStatus.NOT_FOUND, "요청하신 클라이밍장 정보를 찾을 수 없습니다.."),

    GET_RECORD_YEAR(successCode(),HttpStatus.OK,"사용자의 년간 통계 기록이 조회되었습니다."),
    GET_RECORD_MONTH(successCode(),HttpStatus.OK,"사용자의 월간 통계 기록이 조회되었습니다."),
    GET_RECORD_WEEKLY(successCode(),HttpStatus.OK,"사용자의 주간 통계 기록이 조회되었습니다."),
    GET_RECORD_DAILY(successCode(),HttpStatus.OK,"사용자의 일간 통계 기록이 조회되었습니다."),
    GET_CLIMBGROUND_RECORD_YEAR(successCode(),HttpStatus.OK,"사용자가 요청한 클라이밍장 년간 통계 기록이 조회되었습니다."),
    GET_CLIMBGROUND_RECORD_MONTH(successCode(),HttpStatus.OK,"사용자가 요청한 클라이밍장 월간 통계 기록이 조회되었습니다."),
    GET_CLIMBGROUND_RECORD_WEEKLY(successCode(),HttpStatus.OK,"사용자가 요청한 클라이밍장 주간 통계 기록이 조회되었습니다."),
    GET_CLIMBGROUND_RECORD_DAILY(successCode(),HttpStatus.OK,"사용자의 요청한 클라이밍장 일간 통계 기록이 조회되었습니다."),

    GET_DAILY_RECORD(successCode(), HttpStatus.OK, "해당 날짜의 클라이밍 기록이 조회되었습니다."),
    GET_MONTHLY_RECORD(successCode(), HttpStatus.OK, "한달 클라이밍 기록이 조회되었습니다."),

    POST_UNLUCK_CLIMB_GROUND(201,HttpStatus.CREATED,"클라이밍장 해금에 성공했습니다"),
    ALEADY_UNLUCKED(208, HttpStatus.ALREADY_REPORTED,"이미 해금된 클라이밍장입니다."),
    NOT_FOUND_CLIMB_GROUND_OR_USER(404, HttpStatus.NOT_FOUND, "클라이밍장 혹은 유저 정보를 찾을 수 없습니다..");


    private int code;
    private HttpStatus httpStatus;
    private String message;

    private static int successCode() {
        return 200;
    }
}
