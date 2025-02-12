package com.project.backend.userdate.dto.request;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@Setter
public class UserDateCheckAndAddLocationRequestDTO {

//    private Long userId;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private LocalDate date;

}
