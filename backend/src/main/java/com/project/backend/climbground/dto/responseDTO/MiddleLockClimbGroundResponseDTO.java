package com.project.backend.climbground.dto.responseDTO;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;


@Getter
@Setter
@AllArgsConstructor
public class MiddleLockClimbGroundResponseDTO {

    private Long ClimbGroundId;
    private String name;
    private String image;
    private String address;
    private double latitude;
    private double longitude;
    private boolean isLocked;

}
