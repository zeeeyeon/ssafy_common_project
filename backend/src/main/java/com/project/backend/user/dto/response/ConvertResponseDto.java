package com.project.backend.user.dto.response;

import com.project.backend.user.entity.User;
import lombok.Data;

@Data
public class ConvertResponseDto {
    private String password;
    private String username;
    private String phone;
    private String nickname;

    public ConvertResponseDto(User user) {
        this.password = user.getPassword();
        this.username = user.getUsername();
        this.phone = user.getPhone();
        this.nickname = user.getNickname();
    }
}
