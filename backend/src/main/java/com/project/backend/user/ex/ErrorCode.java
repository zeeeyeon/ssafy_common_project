package com.project.backend.user.ex;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.http.HttpStatus;


@Getter
@AllArgsConstructor
public enum ErrorCode {

    USER_NOT_EXIST(HttpStatus.NOT_FOUND, "존재하지 않는 회원입니다."),
    COMMENT_NOT_EXIST(HttpStatus.NOT_FOUND, "존재하지 않는 댓글입니다."),
    POST_NOT_EXIST(HttpStatus.NOT_FOUND, "존재하지 않는 게시물입니다."),
    POSTLIKE_NOT_EXIST(HttpStatus.NOT_FOUND, "해당 사용자의 좋아요가 존재하지 않습니다."),
    DUPLICATE_USER(HttpStatus.CONFLICT, "중복된 사용자가 존재합니다."),
    DUPLICATE_EMAIL(HttpStatus.CONFLICT, "중복된 Email 입니다."),
    SAME_PASSWORD(HttpStatus.BAD_REQUEST, "기존의 비밀번호와 동일합니다."),
    SELF_POSTLIKE_NOT_ALLOWED(HttpStatus.BAD_REQUEST, "자신의 게시물에는 좋아요를 누를 수 없습니다."),
    SELF_COMMENTLIKE_NOT_ALLOWED(HttpStatus.BAD_REQUEST, "자신의 댓글에는 좋아요를 누를 수 없습니다."),
    NOT_YOUR_COMMENT(HttpStatus.BAD_REQUEST, "자신의 댓글이 아닙니다."),
    CANNOT_UNLIKE(HttpStatus.BAD_REQUEST, "좋아요 취소할 수 없습니다."),
    ALREADY_FOLLOWING_USER(HttpStatus.BAD_REQUEST, "이미 팔로우중인 사용자입니다."),
    NOT_FOLLOWING_USER(HttpStatus.BAD_REQUEST, "해당 사용자는 팔로우 중인 사용자가 아닙니다."),
    INCORRECT_ADMIN_PASSWORD(HttpStatus.UNAUTHORIZED, "관리자 암호가 틀려 등록이 불가능합니다."),
    PASSWORD_MISMATCH(HttpStatus.BAD_REQUEST, "입력한 비밀번호가 일치하지 않습니다."),
    RECENT_PASSWORD(HttpStatus.BAD_REQUEST, "최근 3번안에 사용한 비밀번호 입니다."),
    NO_PASSWORD_CHANGE_HISTORY(HttpStatus.NOT_FOUND, "비밀번호 변경 이력이 존재하지 않습니다.");

    private final HttpStatus httpStatus;
    private final String message;
}