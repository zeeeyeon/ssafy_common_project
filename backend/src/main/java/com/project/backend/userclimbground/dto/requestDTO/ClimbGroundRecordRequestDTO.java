package com.project.backend.userclimbground.dto.requestDTO;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.temporal.ChronoField;

@Getter
@Setter
@AllArgsConstructor
public class ClimbGroundRecordRequestDTO {
    private Long userId;
    private Long climbGroundId;
    private LocalDate date;

    public int getYear() {
        return date.getYear();  // ✅ 연도 추출 (2022)
    }

    public int getMonth() {
        return date.getMonthValue();  // ✅ 월 추출 (12)
    }

    public int getDay() {
        return date.getDayOfMonth();
    }

    public int getWeek() {
        return date.get(ChronoField.ALIGNED_WEEK_OF_MONTH);
    }

}
