package com.project.backend.climbground.dto.requsetDTO;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;


@Getter
@Setter
@AllArgsConstructor
public class LockClimbGroundAllRequsetDTO {

    private Long userId;
    private double latitude;
    private double longitude;



}
