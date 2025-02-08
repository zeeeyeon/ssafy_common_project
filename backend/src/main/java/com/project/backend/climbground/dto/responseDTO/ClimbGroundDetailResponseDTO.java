package com.project.backend.climbground.dto.responseDTO;

import com.project.backend.hold.dto.responseDTO.HoldResponseDTO;
import com.project.backend.info.dto.responseDTO.InfoResponseDTO;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class ClimbGroundDetailResponseDTO {

    private Long Id;
    private String name;
    private String address;
    private String image;
    private String number;
    private double latitude;
    private double longitude;
    private String open;
    private String sns_url;
    private List<HoldResponseDTO> holds;
    private List<InfoResponseDTO> infos;

    public ClimbGroundDetailResponseDTO(){
    }

    public ClimbGroundDetailResponseDTO(Long id, String name, String address, String image, String number, double latitude, double longitude, String open, String sns_url, List<HoldResponseDTO> holds, List<InfoResponseDTO> infos) {

        this.Id = id;
        this.name = name;
        this.address = address;
        this.image = image;
        this.number = number;
        this.latitude = latitude;
        this.longitude = longitude;
        this.open = open;
        this.sns_url = sns_url;
        this.holds = holds;
        this.infos = infos;
    }

}
