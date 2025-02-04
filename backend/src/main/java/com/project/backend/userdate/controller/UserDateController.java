package com.project.backend.userdate.controller;

import com.project.backend.common.response.Response;
import com.project.backend.userdate.dto.response.DailyClimbingRecordResponse;
import com.project.backend.userdate.dto.response.MonthlyClimbingRecordResponse;
import com.project.backend.userdate.service.UserDateService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.YearMonth;

import static com.project.backend.common.response.ResponseCode.GET_DAILY_RECORD;
import static com.project.backend.common.response.ResponseCode.GET_MONTHLY_RECORD;

@RestController
@RequestMapping("/api/record")
@RequiredArgsConstructor
public class UserDateController {
    private final UserDateService userDateService;

    // user 가져오는 방법 물어보기
    @GetMapping("daily/{userId}")
    public ResponseEntity<?> getDailyRecord (
            @RequestParam("date") @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate selectedDate,
            @PathVariable Long userId) {

        DailyClimbingRecordResponse dailyRecord = userDateService.getDailyRecord(selectedDate, userId);
        return new ResponseEntity<>(Response.create(GET_DAILY_RECORD, dailyRecord), GET_DAILY_RECORD.getHttpStatus());
    }

    
    @GetMapping("/monthly/{userId}")
    public ResponseEntity<?> getMonthlyRecords(
            @RequestParam("date") @DateTimeFormat(pattern = "yyyy-MM") YearMonth selectedMonth,
            @PathVariable Long userId) {

        MonthlyClimbingRecordResponse monthlyRecords = userDateService.getMonthlyRecords(selectedMonth, userId);
        return new ResponseEntity<>(Response.create(GET_MONTHLY_RECORD, monthlyRecords), GET_MONTHLY_RECORD.getHttpStatus());
    }



//    @GetMapping("/test")
//    public void test(@AuthenticationPrincipal UserPrincipal userPrincipal) throws JsonProcessingException {
//        ObjectMapper objectMapper = new ObjectMapper();
//        System.out.println(objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(userPrincipal));
//    }

}
