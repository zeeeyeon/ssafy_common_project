package com.project.backend.user.dto.response;

import com.project.backend.user.entity.User;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
public class UserInfoResponseDto {
    private String username;
    private float height;
    private float reach;
    private LocalDateTime startDate;

    public UserInfoResponseDto(User user) {
        this.username = user.getUsername();
        this.height = user.getHeight();
        this.reach = user.getReach();
        this.startDate = user.getStartDate();
    }
}
