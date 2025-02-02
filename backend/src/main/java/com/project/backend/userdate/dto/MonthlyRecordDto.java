package com.project.backend.userdate.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class MonthlyRecordDto {
    private int day;
    private long totalCount;
}
