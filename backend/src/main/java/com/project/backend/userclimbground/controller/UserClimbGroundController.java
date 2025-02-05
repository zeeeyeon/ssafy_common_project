package com.project.backend.userclimbground.controller;

import com.project.backend.common.response.Response;
import com.project.backend.common.response.ResponseCode;
import com.project.backend.userclimbground.dto.requestDTO.ClimbGroundRecordRequestDTO;
import com.project.backend.userclimbground.dto.requestDTO.ClimbRecordRequestDTO;
import com.project.backend.userclimbground.dto.requestDTO.UnlockClimbGroundRequsetDTO;
import com.project.backend.userclimbground.dto.responseDTO.ClimbGroundRecordResponseDTO;
import com.project.backend.userclimbground.dto.responseDTO.ClimbRecordResponseDTO;
import com.project.backend.userclimbground.service.UserClimbGroundServiceImp;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import static com.project.backend.common.response.ResponseCode.*;

@RestController
@RequestMapping("/api/user-climbground")
@RequiredArgsConstructor
public class UserClimbGroundController {

    private final UserClimbGroundServiceImp userClimbGroundService;

    // 통계 페이지 년별 조회
    @GetMapping("/year")
    public ResponseEntity<?> getClimbRecordsYear(@RequestBody ClimbRecordRequestDTO requestDTO) {
        ClimbRecordResponseDTO responseDTO = userClimbGroundService.getUserClimbRecordYear(requestDTO);

        return new ResponseEntity<>(Response.create(GET_RECORD_YEAR, responseDTO), GET_RECORD_YEAR.getHttpStatus());
    }

    // 통계 페이지 달별 조회
    @GetMapping("/monthly")
    public ResponseEntity<?> getClimbRecordsMonth(@RequestBody ClimbRecordRequestDTO requestDTO) {
        ClimbRecordResponseDTO responseDTO = userClimbGroundService.getUserClimbRecordMonth(requestDTO);

        return new ResponseEntity<>(Response.create(GET_RECORD_MONTH, responseDTO), GET_RECORD_MONTH.getHttpStatus());

    }

    @GetMapping("/weekly")
    public ResponseEntity<?> getClimbRecordsWeek(@RequestBody ClimbRecordRequestDTO requestDTO) {
        ClimbRecordResponseDTO responseDTO = userClimbGroundService.getUserClimbRecordWeek(requestDTO);

        return new ResponseEntity<>(Response.create(GET_RECORD_WEEKLY, responseDTO), GET_RECORD_WEEKLY.getHttpStatus());

    }

    @GetMapping("/daily")
    public ResponseEntity<?> getClimbRecordsDay(@RequestBody ClimbRecordRequestDTO requestDTO) {
        ClimbRecordResponseDTO responseDTO = userClimbGroundService.getUserClimbRecordDay(requestDTO);

        return new ResponseEntity<>(Response.create(GET_RECORD_DAILY, responseDTO), GET_RECORD_DAILY.getHttpStatus());

    }

    @PostMapping("/unlock")
    public ResponseEntity<?> postUnlockClimbGround(@RequestBody UnlockClimbGroundRequsetDTO requestDTO) {
        ResponseCode responseCode = userClimbGroundService.saveUnlockClimbGround(requestDTO);
        return new ResponseEntity<>(Response.create(responseCode,null), responseCode.getHttpStatus());
    }

    @GetMapping("/climb/year")
    public ResponseEntity<?> getClimbGroundRecordYear(@RequestBody ClimbGroundRecordRequestDTO requestDTO) {
        ClimbGroundRecordResponseDTO responseDTO= userClimbGroundService.getUserClimbGroundRecordYear(requestDTO);
        return new ResponseEntity<>(Response.create(GET_CLIMBGROUND_RECORD_YEAR, responseDTO), GET_CLIMBGROUND_RECORD_YEAR.getHttpStatus());
    }

    @GetMapping("/climb/monthly")
    public ResponseEntity<?> getClimbGroundRecordMonth(@RequestBody ClimbGroundRecordRequestDTO requestDTO) {
        ClimbGroundRecordResponseDTO responseDTO= userClimbGroundService.getUserClimbGroundRecordMonth(requestDTO);
        return new ResponseEntity<>(Response.create(GET_CLIMBGROUND_RECORD_MONTH, responseDTO), GET_CLIMBGROUND_RECORD_MONTH.getHttpStatus());

    }

    @GetMapping("/climb/weekly")
    public ResponseEntity<?> getClimbGroundRecordWeek(@RequestBody ClimbGroundRecordRequestDTO requestDTO) {
        ClimbGroundRecordResponseDTO responseDTO= userClimbGroundService.getUserClimbGroundRecordWeek(requestDTO);
        return new ResponseEntity<>(Response.create(GET_CLIMBGROUND_RECORD_WEEKLY, responseDTO), GET_CLIMBGROUND_RECORD_WEEKLY.getHttpStatus());

    }

    @GetMapping("/climb/daily")
    public ResponseEntity<?> getClimbGroundRecordDaily(@RequestBody ClimbGroundRecordRequestDTO requestDTO) {
        ClimbGroundRecordResponseDTO responseDTO= userClimbGroundService.getUserClimbGroundRecordDay(requestDTO);
        return new ResponseEntity<>(Response.create(GET_CLIMBGROUND_RECORD_DAILY, responseDTO), GET_CLIMBGROUND_RECORD_DAILY.getHttpStatus());

    }
    
}
