package com.project.backend.info.dto.responseDTO;

import lombok.Getter;

@Getter
public class InfoResponseDTO {

    private String info;

    public InfoResponseDTO(String info) {
        this.info = info;
    }
}
