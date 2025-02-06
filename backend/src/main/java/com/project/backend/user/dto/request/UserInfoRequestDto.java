package com.project.backend.user.dto.request;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class UserInfoRequestDto {
    private String username;
    private float height;
    private float reach;
    private LocalDateTime startDate;
}
