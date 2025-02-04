package com.project.backend.climbground.dto.requsetDTO;


import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
public class ClimbGroundSearchRequestDTO {
    private String keyword;
    private BigDecimal latitude;
    private BigDecimal longitude;
}
