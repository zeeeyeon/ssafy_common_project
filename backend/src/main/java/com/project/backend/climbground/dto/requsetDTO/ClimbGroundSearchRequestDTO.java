package com.project.backend.climbground.dto.requsetDTO;


import lombok.Getter;
import lombok.Setter;


@Getter
@Setter
public class ClimbGroundSearchRequestDTO {
    private String keyword;
    private double latitude;
    private double longitude;

}
