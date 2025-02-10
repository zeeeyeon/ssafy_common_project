package com.project.backend.climbground.dto.requsetDTO;

import lombok.Getter;
import lombok.Setter;


@Setter
@Getter
public class ClimbGroundAllRequestDTO {

    private double latitude;
    private double longitude;

    public ClimbGroundAllRequestDTO(double latitude, double longitude) {
        this.latitude = latitude;
        this.longitude = longitude;
    }
}
