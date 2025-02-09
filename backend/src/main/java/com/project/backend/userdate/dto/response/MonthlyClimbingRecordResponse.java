package com.project.backend.userdate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
public class MonthlyClimbingRecordResponse {
    private int year;
    private int month;
    private List<DayRecord> records;

    @Builder
    public MonthlyClimbingRecordResponse(int year, int month, List<DayRecord> records) {
        this.year = year;
        this.month = month;
        this.records = records;
    }

    @Getter
    @AllArgsConstructor
    public static class DayRecord {
        private int day;
        private boolean hasRecord;
        private long totalCount;
    }
}
