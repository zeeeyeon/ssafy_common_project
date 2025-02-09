package com.project.backend.userdate.dto.response;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
public class MonthlyClimbingRecordResponse {
    private int year;
    private int month;
    private List<DayRecord> records;

    @JsonCreator
    public MonthlyClimbingRecordResponse(
            @JsonProperty("year") int year,
            @JsonProperty("month") int month,
            @JsonProperty("records") List<DayRecord> records) {
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
