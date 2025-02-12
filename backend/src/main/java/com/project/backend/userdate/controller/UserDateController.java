package com.project.backend.userdate.controller;

import com.project.backend.common.advice.exception.CustomException;
import com.project.backend.common.response.Response;
import com.project.backend.common.response.ResponseCode;
import com.project.backend.user.auth.CustomUserDetails;
import com.project.backend.userdate.dto.ClimbGroundWithDistance;
import com.project.backend.userdate.dto.request.UserDateCheckAndAddLocationRequestDTO;
import com.project.backend.userdate.dto.request.UserDateCheckAndAddRequestDTO;
import com.project.backend.userdate.dto.response.*;
import com.project.backend.userdate.service.UserDateService;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
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
            @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        Long userId = userDetails.getUser().getId();
        DailyClimbingRecordResponse dailyRecord = userDateService.getDailyRecord(selectedDate, userId);
        return new ResponseEntity<>(Response.create(GET_DAILY_RECORD, dailyRecord), GET_DAILY_RECORD.getHttpStatus());
    }

    @GetMapping("/monthly/{userId}")
    public ResponseEntity<?> getMonthlyRecords(
            @RequestParam("date") @DateTimeFormat(pattern = "yyyy-MM") YearMonth selectedMonth,
            @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        Long userId = userDetails.getUser().getId();
        MonthlyClimbingRecordResponse monthlyRecords = userDateService.getMonthlyRecords(selectedMonth, userId);
        return new ResponseEntity<>(Response.create(GET_MONTHLY_RECORD, monthlyRecords), GET_MONTHLY_RECORD.getHttpStatus());
    }


    @PostMapping("/unlock")
    public ResponseEntity<?> startRecord (@AuthenticationPrincipal CustomUserDetails userDetails , @RequestBody UserDateCheckAndAddRequestDTO requestDTO) {
        Long userId = userDetails.getUser().getId();
        ChallUnlockResponseDTO responseDTO = userDateService.ChallUserDateCheckAndAdd(userId,requestDTO);
        if (responseDTO != null) {
            if (responseDTO.getUserDate().isNewlyCreated()){ //새로 생성 한것 이면
                return new ResponseEntity<>(Response.create(POST_USER_DATE, responseDTO), POST_USER_DATE.getHttpStatus());
            }
            // 이미 전에 생성된적 있으면
            return new ResponseEntity<>(Response.create(ALEADY_USER_DATE, responseDTO), ALEADY_USER_DATE.getHttpStatus());
        }
        throw new CustomException(ResponseCode.BAD_REQUEST);
    }

    @PostMapping("/start/near-location")
    public ResponseEntity<?> startNearLocationRecord (@AuthenticationPrincipal CustomUserDetails userDetails,@RequestBody UserDateCheckAndAddLocationRequestDTO requestDTO) {
        Long userId = userDetails.getUser().getId();
        UserDateCheckAndAddResponseDTO responseDTO = userDateService.UserDateCheckAndAdd(userId,requestDTO);
        if (responseDTO != null) {
            if (responseDTO.isNewlyCreated()){ //새로 생성 한것 이면
                return new ResponseEntity<>(Response.create(POST_USER_DATE, responseDTO), POST_USER_DATE.getHttpStatus());
            }
            // 이미 전에 생성된적 있으면
            return new ResponseEntity<>(Response.create(ALEADY_USER_DATE, responseDTO), ALEADY_USER_DATE.getHttpStatus());
        }
        throw new CustomException(ResponseCode.BAD_REQUEST);
    }
}