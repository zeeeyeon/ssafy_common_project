package com.project.backend.user.dto.request;

import com.project.backend.user.entity.User;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.time.LocalDateTime;

@Data
public class ConvertRequestDto {

    @Pattern(regexp = "^(?=.*[a-zA-Z])((?=.*\\d)|(?=.*\\W)).{7,128}+$", message = "대소문자, 숫자, 특수문자 조합으로 8 ~ 128자리여야 합니다.")
    private String password;
    @NotBlank(message = "이름은 공백일 수 없습니다.")
    private String username;
    @NotBlank(message = "전화번호는 공백일 수 없습니다.")
    private String phone;
    @NotBlank(message = "닉네임은 공백일 수 없습니다.")
    private String nickname;

    public User toUserEntity(BCryptPasswordEncoder passwordEncoder) {
        return User
                .builder()
                .password(passwordEncoder.encode(password))
                .username(username)
                .phone(phone)
                .nickname(nickname)
                .startDate(LocalDateTime.now())
                .createDate(LocalDateTime.now())
                .updateDate(LocalDateTime.now())
                .build();
    }
}