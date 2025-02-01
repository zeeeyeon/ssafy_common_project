package com.project.backend.userclimbground.dto.requestDTO;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
public class ClimbRecordRequestDTO {

    private Long userId;
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

}
