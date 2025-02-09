package com.project.backend.userdate.controller;

import com.project.backend.common.advice.exception.CustomException;
import com.project.backend.common.response.Response;
import com.project.backend.common.response.ResponseCode;
import com.project.backend.userdate.dto.request.UserDateCheckAndAddLocationRequestDTO;
import com.project.backend.userdate.dto.request.UserDateCheckAndAddRequestDTO;
import com.project.backend.userdate.dto.response.ClimbIdAndNameStatus;
import com.project.backend.userdate.dto.response.DailyClimbingRecordResponse;
import com.project.backend.userdate.dto.response.MonthlyClimbingRecordResponse;
import com.project.backend.userdate.dto.response.UserDateCheckAndAddResponseDTO;
import com.project.backend.userdate.service.UserDateService;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.YearMonth;

import static com.project.backend.common.response.ResponseCode.*;

import static com.project.backend.common.response.ResponseCode.GET_DAILY_RECORD;
import static com.project.backend.common.response.ResponseCode.GET_MONTHLY_RECORD;

@RestController
@RequestMapping("/api/record")
@RequiredArgsConstructor
public class UserDateController {
    private final UserDateService userDateService;

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
        return ResponseEntity.ok(Response.create(GET_MONTHLY_RECORD, monthlyRecords));
    }

    // user_date 생성
    @PostMapping("/start")
    @CacheEvict(value = "monthlyRecords", key = "#RequestDTO.userId + '_' + 'monthly_' + #RequestDTO.date")
    public ResponseEntity<?> startRecord (@RequestBody UserDateCheckAndAddRequestDTO RequestDTO) {
        UserDateCheckAndAddResponseDTO responseDTO = userDateService.UserDateCheckAndAdd(RequestDTO);
        if (responseDTO != null) {
            if (responseDTO.isNewlyCreated()){ //새로 생성 한것 이면
                return new ResponseEntity<>(Response.create(POST_USER_DATE, responseDTO), POST_USER_DATE.getHttpStatus());
            }
            // 이미 전에 생성된적 있으면
            return new ResponseEntity<>(Response.create(ALEADY_USER_DATE, responseDTO), ALEADY_USER_DATE.getHttpStatus());
        }
        throw new CustomException(ResponseCode.BAD_REQUEST);
    }

    @PostMapping("/start/near-location")
    public ResponseEntity<?> startNearLocationRecord (@RequestBody UserDateCheckAndAddLocationRequestDTO requestDTO) {
        ClimbIdAndNameStatus climbStatus = userDateService.findClimbIdAndName(requestDTO);
        UserDateCheckAndAddRequestDTO nextRequestDTO= new UserDateCheckAndAddRequestDTO(requestDTO.getUserId(), climbStatus.getClimbId() ,requestDTO.getDate());
        UserDateCheckAndAddResponseDTO responseDTO = userDateService.UserDateCheckAndAdd(nextRequestDTO);
        if (responseDTO != null) {
            if (responseDTO.isNewlyCreated()){ //새로 생성 한것 이면
                return new ResponseEntity<>(Response.create(POST_USER_DATE, responseDTO), POST_USER_DATE.getHttpStatus());
            }
            // 이미 전에 생성된적 있으면
            return new ResponseEntity<>(Response.create(ALEADY_USER_DATE, responseDTO), ALEADY_USER_DATE.getHttpStatus());
        }
        throw new CustomException(ResponseCode.BAD_REQUEST);
    }

    @GetMapping("/test/get")
    public String test01() {
        return "get";
    }


    @PostMapping("/test/post")
    public String test02(@RequestBody int userId ) {
        return "post";
    }
}