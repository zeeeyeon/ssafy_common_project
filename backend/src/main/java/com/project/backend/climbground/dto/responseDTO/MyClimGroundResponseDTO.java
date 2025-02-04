package com.project.backend.climbground.dto.responseDTO;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class MyClimGroundResponseDTO {
    private Long Id;
    private String name;
    private String image;
    private String address;
}
