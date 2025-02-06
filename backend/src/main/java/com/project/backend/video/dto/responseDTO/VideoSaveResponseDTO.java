package com.project.backend.video.dto.responseDTO;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class VideoSaveResponseDTO {

    private Long videoId;
    private String url;
    private Long climbRecordId;
}
