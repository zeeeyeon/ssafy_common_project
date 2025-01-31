package com.project.backend.climbground.dto.requsetDTO;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Setter
@Getter
public class ClimbGroundAllRequestDTO {

    private BigDecimal latitude;
    private BigDecimal longitude;

    public ClimbGroundAllRequestDTO(BigDecimal latitude, BigDecimal longitude) {
        this.latitude = latitude;
        this.longitude = longitude;
    }
}
