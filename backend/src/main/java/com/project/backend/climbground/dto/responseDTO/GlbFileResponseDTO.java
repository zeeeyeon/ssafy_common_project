package com.project.backend.climbground.dto.responseDTO;

import com.project.backend.climbground.entity.GlbFile;
import jakarta.persistence.Column;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;

import java.time.LocalDateTime;

@Getter
@Setter
public class GlbFileResponseDTO {
    private String fileName;    // S3에 저장된 파일명 (UUID 포함)
    private String fileType;    // 파일 MIME 타입
    private String filePath;    // S3 URL
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public GlbFileResponseDTO(GlbFile glbFile) {
        this.fileName = glbFile.getFileName();
        this.fileType = glbFile.getFileType();
        this.filePath = glbFile.getFilePath();
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
}
