package com.project.backend.user.ex;

import lombok.Getter;

@Getter
public class CustomApiException extends RuntimeException {

    private final ErrorCode errorCode;

    public CustomApiException(ErrorCode errorCode){
        super(errorCode.getMessage());
        this.errorCode = errorCode;
    }
}
