package com.project.backend.userclimbground.controller;

import com.project.backend.common.ApiResponse;
import com.project.backend.common.ResponseType;
import com.project.backend.userclimbground.dto.requestDTO.ClimbRecordRequestDTO;
import com.project.backend.userclimbground.dto.responseDTO.ClimbRecordResponseDTO;
import com.project.backend.userclimbground.service.UserClimbGroundServiceImp;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/statistics")
@RequiredArgsConstructor
public class UserClimbGroundController {

    private final UserClimbGroundServiceImp userClimbGroundService;

    // 통계 페이지 년별 조회
    @GetMapping("/year")
    public ApiResponse<?> getClimbRecordsYear(@ModelAttribute ClimbRecordRequestDTO requestDTO) {
        ClimbRecordResponseDTO responseDTO = userClimbGroundService.getUserClimbRecordYear(requestDTO);

        return ApiResponse.apiResponse(ResponseType.SUCCESS,"data",responseDTO);
    }

    // 통계 페이지 년별 조회
    @GetMapping("/monthly")
    public ApiResponse<?> getClimbRecordsMonth(@ModelAttribute ClimbRecordRequestDTO requestDTO) {
        ClimbRecordResponseDTO responseDTO = userClimbGroundService.getUserClimbRecordMonth(requestDTO);

        return ApiResponse.apiResponse(ResponseType.SUCCESS,"data",responseDTO);
    }

    @GetMapping("/weekly")
    public ApiResponse<?> getClimbRecordsWeek(@ModelAttribute ClimbRecordRequestDTO requestDTO) {
        ClimbRecordResponseDTO responseDTO = userClimbGroundService.getUserClimbRecordWeek(requestDTO);

        return ApiResponse.apiResponse(ResponseType.SUCCESS,"data",responseDTO);
    }

    @GetMapping("/daily")
    public ApiResponse<?> getClimbRecordsDay(@ModelAttribute ClimbRecordRequestDTO requestDTO) {
        ClimbRecordResponseDTO responseDTO = userClimbGroundService.getUserClimbRecordDay(requestDTO);

        return ApiResponse.apiResponse(ResponseType.SUCCESS,"data",responseDTO);
    }
    
}
