package com.project.backend.climb.center.dto.responseDTO;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ClimbResponseDTO {

    private Long Id;
    private String name;
    private String image;
    private String address;
    private String open;
    private String number;
    private String sns_url;

    public ClimbResponseDTO(Long Id, String name, String image, String address, String open, String number,String sns_url) {
        this.Id = Id;
        this.name = name;
        this.image = image;
        this.address = address;
        this.open = open;
        this.number = number;
        this.sns_url = sns_url;
    }
}
