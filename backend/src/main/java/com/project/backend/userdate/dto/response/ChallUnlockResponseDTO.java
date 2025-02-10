package com.project.backend.userdate.dto.response;

import com.project.backend.userclimbground.dto.responseDTO.UnLockClimbGroundDetailResponseDTO;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class ChallUnlockResponseDTO {
    private UserDateCheckAndAddResponseDTO userDate;
    private UnLockClimbGroundDetailResponseDTO detail;

}
