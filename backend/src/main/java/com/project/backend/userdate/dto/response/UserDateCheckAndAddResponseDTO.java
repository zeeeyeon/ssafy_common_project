package com.project.backend.userdate.dto.response;


import com.project.backend.hold.dto.responseDTO.HoldResponseDTO;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class UserDateCheckAndAddResponseDTO {

    private Long userDateId;
    private String name;
    private List<HoldResponseDTO> holds;
    private boolean isNewlyCreated;

}
