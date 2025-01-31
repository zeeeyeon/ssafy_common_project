package com.project.backend.climbground.dto.responseDTO;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ClimbGroundAllResponseDTO {

    private Long Id;
    private String name;
    private String image;
    private String address;
    private double distance;

    public ClimbGroundAllResponseDTO(Long Id, String name, String image, String address, double distance) {
        this.Id = Id;
        this.name = name;
        this.image = image;
        this.address = address;
        this.distance = distance;
    }
}
