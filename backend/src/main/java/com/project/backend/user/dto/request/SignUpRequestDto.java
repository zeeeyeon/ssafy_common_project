package com.project.backend.user.dto.request;

import com.project.backend.user.entity.User;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.time.LocalDateTime;

@Data
public class SignUpRequestDto {
    @Email(regexp = "^[a-zA-Z0-9]+@[0-9a-zA-Z]+\\.[a-z]+$", message = "이메일 형식이어야 합니다.")
    private String email;
    @Pattern(regexp = "^(?=.*[a-zA-Z])((?=.*\\d)|(?=.*\\W)).{7,128}+$", message = "대소문자, 숫자, 특수문자 조합으로 8 ~ 128자리여야 합니다.")
    private String password;
    @Pattern(regexp = "^(?=.*[a-zA-Z])((?=.*\\d)|(?=.*\\W)).{7,128}+$", message = "대소문자, 숫자, 특수문자 조합으로 8 ~ 128자리여야 합니다.")
    private String passwordConfirm;
    @NotBlank(message = "이름은 공백일 수 없습니다.")
    private String username;
    @NotBlank(message = "전화번호는 공백일 수 없습니다.")
    private String phone;
    @NotBlank(message = "닉네임은 공백일 수 없습니다.")
    private String nickname;

    public User toUserEntity(BCryptPasswordEncoder passwordEncoder) {
        return User
                .builder()
                .email(email)
                .password(passwordEncoder.encode(password))
                .username(username)
                .phone(phone)
                .nickname(nickname)
                .reach((float) 0)
                .height((float) 0)
                .profileImageUrl("https://ssafy-ori-bucket.s3.ap-northeast-2.amazonaws.com/profile_default.png")
                .createDate(LocalDateTime.now())
                .updateDate(LocalDateTime.now())
                .build();
    }
}
