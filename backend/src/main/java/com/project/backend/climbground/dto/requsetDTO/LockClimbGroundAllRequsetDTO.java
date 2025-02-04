package com.project.backend.climbground.dto.requsetDTO;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
@AllArgsConstructor
public class LockClimbGroundAllRequsetDTO {

    private Long userId;
    private BigDecimal latitude;
    private BigDecimal longitude;



}
