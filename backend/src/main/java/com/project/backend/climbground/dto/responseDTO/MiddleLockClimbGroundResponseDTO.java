package com.project.backend.climbground.dto.responseDTO;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
@AllArgsConstructor
public class MiddleLockClimbGroundResponseDTO {

    private Long ClimbGroundId;
    private String name;
    private String image;
    private String address;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private boolean isLocked;

}
