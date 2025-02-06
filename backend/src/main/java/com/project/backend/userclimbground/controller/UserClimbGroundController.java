package com.project.backend.userclimbground.controller;

import com.project.backend.common.response.Response;
import com.project.backend.common.response.ResponseCode;
import com.project.backend.userclimbground.dto.requestDTO.UnlockClimbGroundRequsetDTO;
import com.project.backend.userclimbground.dto.responseDTO.ClimbGroundRecordResponseDTO;
import com.project.backend.userclimbground.dto.responseDTO.ClimbRecordResponseDTO;
import com.project.backend.userclimbground.service.UserClimbGroundServiceImp;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
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
    public ResponseEntity<?> getClimbRecordsYear(@RequestParam(name = "userId") Long userId, @RequestParam(name = "date") @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date) {
        ClimbRecordResponseDTO responseDTO = userClimbGroundService.getUserClimbRecordYear(userId, date);

        return new ResponseEntity<>(Response.create(GET_RECORD_YEAR, responseDTO), GET_RECORD_YEAR.getHttpStatus());
    }

    // 통계 페이지 달별 조회
    @GetMapping("/monthly")
    public ResponseEntity<?> getClimbRecordsMonth(@RequestParam(name = "userId") Long userId, @RequestParam(name = "date") @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date) {
        ClimbRecordResponseDTO responseDTO = userClimbGroundService.getUserClimbRecordMonth(userId,date);

        return new ResponseEntity<>(Response.create(GET_RECORD_MONTH, responseDTO), GET_RECORD_MONTH.getHttpStatus());

    }

    @GetMapping("/weekly")
    public ResponseEntity<?> getClimbRecordsWeek(@RequestParam(name = "userId") Long userId, @RequestParam(name = "date") @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date) {
        ClimbRecordResponseDTO responseDTO = userClimbGroundService.getUserClimbRecordWeek(userId, date);

        return new ResponseEntity<>(Response.create(GET_RECORD_WEEKLY, responseDTO), GET_RECORD_WEEKLY.getHttpStatus());

    }

    @GetMapping("/daily")
    public ResponseEntity<?> getClimbRecordsDay(@RequestParam(name = "userId") Long userId, @RequestParam(name = "date") @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date) {
        ClimbRecordResponseDTO responseDTO = userClimbGroundService.getUserClimbRecordDay(userId,date);

        return new ResponseEntity<>(Response.create(GET_RECORD_DAILY, responseDTO), GET_RECORD_DAILY.getHttpStatus());

    }

    @PostMapping("/unlock")
    public ResponseEntity<?> postUnlockClimbGround(@RequestBody UnlockClimbGroundRequsetDTO requestDTO) {
        ResponseCode responseCode = userClimbGroundService.saveUnlockClimbGround(requestDTO);
        return new ResponseEntity<>(Response.create(responseCode,null), responseCode.getHttpStatus());
    }

    @GetMapping("/climb/year")
    public ResponseEntity<?> getClimbGroundRecordYear(@RequestParam(name = "userId") Long userId, @RequestParam(name = "climbGroundId") Long climbGroundId,@RequestParam(name = "date") @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date) {
        ClimbGroundRecordResponseDTO responseDTO= userClimbGroundService.getUserClimbGroundRecordYear(userId, climbGroundId, date);
        return new ResponseEntity<>(Response.create(GET_CLIMBGROUND_RECORD_YEAR, responseDTO), GET_CLIMBGROUND_RECORD_YEAR.getHttpStatus());
    }

    @GetMapping("/climb/monthly")
    public ResponseEntity<?> getClimbGroundRecordMonth(@RequestParam(name = "userId") Long userId, @RequestParam(name = "climbGroundId") Long climbGroundId,@RequestParam(name = "date") @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date) {
        ClimbGroundRecordResponseDTO responseDTO= userClimbGroundService.getUserClimbGroundRecordMonth(userId, climbGroundId, date);
        return new ResponseEntity<>(Response.create(GET_CLIMBGROUND_RECORD_MONTH, responseDTO), GET_CLIMBGROUND_RECORD_MONTH.getHttpStatus());

    }

    @GetMapping("/climb/weekly")
    public ResponseEntity<?> getClimbGroundRecordWeek(@RequestParam(name = "userId") Long userId, @RequestParam(name = "climbGroundId") Long climbGroundId,@RequestParam(name = "date") @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date) {
        ClimbGroundRecordResponseDTO responseDTO= userClimbGroundService.getUserClimbGroundRecordWeek(userId, climbGroundId, date);
        return new ResponseEntity<>(Response.create(GET_CLIMBGROUND_RECORD_WEEKLY, responseDTO), GET_CLIMBGROUND_RECORD_WEEKLY.getHttpStatus());

    }

    @GetMapping("/climb/daily")
    public ResponseEntity<?> getClimbGroundRecordDaily(@RequestParam(name = "userId") Long userId, @RequestParam(name = "climbGroundId") Long climbGroundId,@RequestParam(name = "date") @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date) {
        ClimbGroundRecordResponseDTO responseDTO= userClimbGroundService.getUserClimbGroundRecordDay(userId, climbGroundId, date);
        return new ResponseEntity<>(Response.create(GET_CLIMBGROUND_RECORD_DAILY, responseDTO), GET_CLIMBGROUND_RECORD_DAILY.getHttpStatus());

    }
    
}
