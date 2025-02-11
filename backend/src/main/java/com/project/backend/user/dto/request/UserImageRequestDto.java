package com.project.backend.user.dto.request;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class UserImageRequestDto {
    private MultipartFile profileImageUrl;
}
