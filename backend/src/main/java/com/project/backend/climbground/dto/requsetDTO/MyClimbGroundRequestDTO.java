package com.project.backend.climbground.dto.requsetDTO;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class MyClimbGroundRequestDTO {
    List<Long> climbGroundIds;
}
