package com.project.backend.userdate.dto.response;

import lombok.*;

import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
public class AlbumResponseDTO {

    private LocalDate date;
    private boolean isSuccess;

    List<AlbumObjcet> albumObject;

    public AlbumResponseDTO(LocalDate date, boolean isSuccess) {
        this.date = date;
        this.isSuccess = isSuccess;
    }

}
