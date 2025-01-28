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

    public ClimbGroundAllResponseDTO(Long Id, String name, String image, String address) {
        this.Id = Id;
        this.name = name;
        this.image = image;
        this.address = address;
    }
}
