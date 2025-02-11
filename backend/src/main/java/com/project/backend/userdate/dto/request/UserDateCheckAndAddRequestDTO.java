package com.project.backend.userdate.dto.request;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@Setter
@AllArgsConstructor
public class UserDateCheckAndAddRequestDTO {
//    private Long userId;
    private Long climbGroundId;
    private BigDecimal latitude;
    private BigDecimal longitude;
}
