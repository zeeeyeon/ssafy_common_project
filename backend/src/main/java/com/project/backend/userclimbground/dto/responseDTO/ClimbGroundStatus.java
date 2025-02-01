package com.project.backend.userclimbground.dto.responseDTO;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class ClimbGroundStatus {
    private int climbGround;
    private int visited;
    private List<Long> list;
}
