package com.project.backend.userdate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
public class MonthlyClimbingRecordResponse {
    private int year;
    private int month;
    private List<DayRecord> records;

    @Getter
    @AllArgsConstructor
    public static class DayRecord {
        private int day;
        private boolean hasRecord;
        private long totalCount;
    }
}
