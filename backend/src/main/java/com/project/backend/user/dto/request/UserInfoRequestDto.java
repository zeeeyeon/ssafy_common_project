package com.project.backend.user.dto.request;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class UserInfoRequestDto {
    private String nickname;
    private Float height;
    private Float reach;
    private LocalDateTime startDate;
}
