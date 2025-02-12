package com.project.backend.record.dto.requestDTO;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import org.springframework.web.multipart.MultipartFile;

@Getter
@Setter
@AllArgsConstructor
public class RecordSaveRequestDTO {
//    private Long userId;
    private Long userDateId;
    private Boolean isSuccess;
    private MultipartFile file;
    private Long holdId;
}
