package com.project.backend.userdate.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
@AllArgsConstructor
public class ClimbGroundWithDistance {

    private Long climbGroundId;
    private String name;
    private Double distance;

}
