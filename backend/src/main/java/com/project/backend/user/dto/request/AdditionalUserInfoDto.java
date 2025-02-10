package com.project.backend.user.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

@Data
public class AdditionalUserInfoDto {
    @Pattern(regexp = "^(?=.*[a-zA-Z])((?=.*\\d)|(?=.*\\W)).{7,128}+$", message = "대소문자, 숫자, 특수문자 조합으로 8 ~ 128자리여야 합니다.")
    private String password;
    @NotBlank(message = "닉네임은 공백일 수 없습니다.")
    private String nickname;
    @NotBlank(message = "이름은 공백일 수 없습니다.")
    private String username;
    @NotBlank(message = "전화번호는 공백일 수 없습니다.")
    private String phone;

    private String accessToken;
}
