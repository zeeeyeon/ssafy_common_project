package com.project.backend.userclimbground.dto.responseDTO;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@AllArgsConstructor
public class ClimbRecordResponseDTO {

    private ClimbGroundStatus climbground;
    private int success;
    private double success_rate;
    private int tryCount;
    private List<HoldStats> holds;

}
