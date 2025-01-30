package com.project.backend.user.dto.response;


import com.project.backend.common.ResponseType;
import com.project.backend.user.dto.ResponseDto;
import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

@Getter
@AllArgsConstructor
public class SignUpResponseDto extends ResponseDto {

    private SignUpResponseDto(ResponseType responseType) {
        super(responseType.getCode(), responseType.getMessage(), responseType.getHttpStatus());
    }

    public static ResponseEntity<?> success() {
        SignUpResponseDto result = new SignUpResponseDto(ResponseType.SUCCESS);
        return ResponseEntity.status(HttpStatus.OK).body(result);
    }

    public static ResponseEntity<?> existedUserEmail() {
        SignUpResponseDto result = new SignUpResponseDto(ResponseType.EXISTED_USER_EMAIL);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(result);
    }

    public static ResponseEntity<?> existedUserPhone() {
        SignUpResponseDto result = new SignUpResponseDto(ResponseType.EXISTED_USER_PHONE);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(result);
    }

    public static ResponseEntity<?> existedUserNickname() {
        SignUpResponseDto result = new SignUpResponseDto(ResponseType.EXISTED_USER_NICKNAME);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(result);
    }

}
