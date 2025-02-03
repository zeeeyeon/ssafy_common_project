package com.project.backend.hold.dto.responseDTO;

import com.project.backend.hold.entity.HoldColorEnum;
import com.project.backend.hold.entity.HoldLevelEnum;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class HoldResponseDTO {

    private Long Id;
    private HoldLevelEnum level;
    private HoldColorEnum color;

    public HoldResponseDTO(Long ID, HoldLevelEnum level, HoldColorEnum color) {
        this.Id = ID;
        this.level = level;
        this.color = color;
    }
}
