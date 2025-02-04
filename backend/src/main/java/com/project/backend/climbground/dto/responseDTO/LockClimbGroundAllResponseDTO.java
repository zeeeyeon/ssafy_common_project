package com.project.backend.climbground.dto.responseDTO;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
@AllArgsConstructor
public class LockClimbGroundAllResponseDTO {

    private Long ClimbGroundId;
    private String name;
    private String image;
    private String address;
    private double distance;
    private boolean isLocked;
}
