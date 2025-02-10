package com.project.backend.userclimbground.controller;

import com.project.backend.common.response.Response;
import com.project.backend.common.response.ResponseCode;
import com.project.backend.user.auth.CustomUserDetails;
import com.project.backend.userclimbground.dto.requestDTO.UnlockClimbGroundRequestDTO;
import com.project.backend.userclimbground.dto.responseDTO.ClimbGroundRecordResponseDTO;
import com.project.backend.userclimbground.dto.responseDTO.ClimbRecordResponseDTO;
import com.project.backend.userclimbground.service.UserClimbGroundServiceImp;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

import static com.project.backend.common.response.ResponseCode.*;

@RestController
@RequestMapping("/api/user-climbground")
@RequiredArgsConstructor
public class UserClimbGroundController {

    private final UserClimbGroundServiceImp userClimbGroundService;

    // 통계 페이지 년별 조회
    @GetMapping("/year")
    public ResponseEntity<?> getClimbRecordsYear(@AuthenticationPrincipal CustomUserDetails userDetails
            , @RequestParam(name = "date") @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date) {
        Long userId = userDetails.getUser().getId();
        ClimbRecordResponseDTO responseDTO = userClimbGroundService.getUserClimbRecordYear(userId, date);

        return new ResponseEntity<>(Response.create(GET_RECORD_YEAR, responseDTO), GET_RECORD_YEAR.getHttpStatus());
    }

    // 통계 페이지 달별 조회
    @GetMapping("/monthly")
    public ResponseEntity<?> getClimbRecordsMonth(@AuthenticationPrincipal CustomUserDetails userDetails
            , @RequestParam(name = "date") @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date) {
        Long userId = userDetails.getUser().getId();
        ClimbRecordResponseDTO responseDTO = userClimbGroundService.getUserClimbRecordMonth(userId,date);

        return new ResponseEntity<>(Response.create(GET_RECORD_MONTH, responseDTO), GET_RECORD_MONTH.getHttpStatus());

    }

    @GetMapping("/weekly")
    public ResponseEntity<?> getClimbRecordsWeek(@AuthenticationPrincipal CustomUserDetails userDetails
            , @RequestParam(name = "date") @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date) {
        Long userId = userDetails.getUser().getId();
        ClimbRecordResponseDTO responseDTO = userClimbGroundService.getUserClimbRecordWeek(userId, date);

        return new ResponseEntity<>(Response.create(GET_RECORD_WEEKLY, responseDTO), GET_RECORD_WEEKLY.getHttpStatus());

    }

    @GetMapping("/daily")
    public ResponseEntity<?> getClimbRecordsDay(@AuthenticationPrincipal CustomUserDetails userDetails
            , @RequestParam(name = "date") @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date) {
        Long userId = userDetails.getUser().getId();
        ClimbRecordResponseDTO responseDTO = userClimbGroundService.getUserClimbRecordDay(userId,date);

        return new ResponseEntity<>(Response.create(GET_RECORD_DAILY, responseDTO), GET_RECORD_DAILY.getHttpStatus());

    }

    @PostMapping("/unlock/{climbground_id}")
    public ResponseEntity<?> postUnlockClimbGround(@AuthenticationPrincipal CustomUserDetails userDetails,
                                                   @PathVariable Long climbground_id) {
        Long userId = userDetails.getUser().getId();
        ResponseCode responseCode = userClimbGroundService.saveUnlockClimbGround(userId,climbground_id);
        return new ResponseEntity<>(Response.create(responseCode,null), responseCode.getHttpStatus());
    }

    @GetMapping("/climb/year")
    public ResponseEntity<?> getClimbGroundRecordYear(@AuthenticationPrincipal CustomUserDetails userDetails
            , @RequestParam(name = "climbGroundId") Long climbGroundId,@RequestParam(name = "date") @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date) {
        Long userId = userDetails.getUser().getId();
        ClimbGroundRecordResponseDTO responseDTO= userClimbGroundService.getUserClimbGroundRecordYear(userId, climbGroundId, date);
        return new ResponseEntity<>(Response.create(GET_CLIMBGROUND_RECORD_YEAR, responseDTO), GET_CLIMBGROUND_RECORD_YEAR.getHttpStatus());
    }

    @GetMapping("/climb/monthly")
    public ResponseEntity<?> getClimbGroundRecordMonth(@AuthenticationPrincipal CustomUserDetails userDetails
            , @RequestParam(name = "climbGroundId") Long climbGroundId,@RequestParam(name = "date") @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date) {
        Long userId = userDetails.getUser().getId();
        ClimbGroundRecordResponseDTO responseDTO= userClimbGroundService.getUserClimbGroundRecordMonth(userId, climbGroundId, date);
        return new ResponseEntity<>(Response.create(GET_CLIMBGROUND_RECORD_MONTH, responseDTO), GET_CLIMBGROUND_RECORD_MONTH.getHttpStatus());

    }

    @GetMapping("/climb/weekly")
    public ResponseEntity<?> getClimbGroundRecordWeek(@AuthenticationPrincipal CustomUserDetails userDetails, @RequestParam(name = "climbGroundId") Long climbGroundId,@RequestParam(name = "date") @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date) {
        Long userId = userDetails.getUser().getId();
        ClimbGroundRecordResponseDTO responseDTO= userClimbGroundService.getUserClimbGroundRecordWeek(userId, climbGroundId, date);
        return new ResponseEntity<>(Response.create(GET_CLIMBGROUND_RECORD_WEEKLY, responseDTO), GET_CLIMBGROUND_RECORD_WEEKLY.getHttpStatus());

    }

    @GetMapping("/climb/daily")
    public ResponseEntity<?> getClimbGroundRecordDaily(@AuthenticationPrincipal CustomUserDetails userDetails, @RequestParam(name = "climbGroundId") Long climbGroundId,@RequestParam(name = "date") @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date) {
        Long userId = userDetails.getUser().getId();
        ClimbGroundRecordResponseDTO responseDTO= userClimbGroundService.getUserClimbGroundRecordDay(userId, climbGroundId, date);
        return new ResponseEntity<>(Response.create(GET_CLIMBGROUND_RECORD_DAILY, responseDTO), GET_CLIMBGROUND_RECORD_DAILY.getHttpStatus());

    }

    
}
