package com.project.backend.record.dto.requestDTO;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class RecordSaveRequestDTO {
    private Long userId;
    private Long userDateId;
    private Boolean isSuccess;
    private Byte video;
    private Long holdId;

}
