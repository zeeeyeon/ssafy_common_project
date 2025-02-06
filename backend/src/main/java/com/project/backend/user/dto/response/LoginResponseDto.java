package com.project.backend.user.dto.response;

import com.project.backend.user.entity.User;
import lombok.Data;

@Data
public class LoginResponseDto {

    private String userName;
    private String userPassword;
    public LoginResponseDto(User user) {
        this.userName = user.getUsername();
        this.userPassword = user.getPassword();
    }
}
