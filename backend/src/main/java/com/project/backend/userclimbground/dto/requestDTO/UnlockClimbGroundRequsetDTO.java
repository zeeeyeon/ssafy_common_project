package com.project.backend.userclimbground.dto.requestDTO;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class UnlockClimbGroundRequsetDTO {

    Long userId;
    Long climbGroundId;

}
