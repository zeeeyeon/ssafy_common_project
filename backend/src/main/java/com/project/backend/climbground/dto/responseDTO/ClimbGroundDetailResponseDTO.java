package com.project.backend.climbground.dto.responseDTO;

import com.project.backend.hold.dto.responseDTO.HoldResponseDTO;
import com.project.backend.info.dto.responseDTO.InfoResponseDTO;
import lombok.Getter;

import java.math.BigDecimal;
import java.util.List;

@Getter
public class ClimbGroundDetailResponseDTO {

    private Long Id;
    private String name;
    private String address;
    private String number;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private String open;
    private String sns_url;
    private List<HoldResponseDTO> holds;
    private List<InfoResponseDTO> infos;

    public ClimbGroundDetailResponseDTO(Long id, String name, String address, String number, BigDecimal latitude, BigDecimal longitude, String open, String sns_url, List<HoldResponseDTO> holds, List<InfoResponseDTO> infos) {

        this.Id = id;
        this.name = name;
        this.address = address;
        this.number = number;
        this.latitude = latitude;
        this.longitude = longitude;
        this.open = open;
        this.sns_url = sns_url;
        this.holds = holds;
        this.infos = infos;
    }

}
