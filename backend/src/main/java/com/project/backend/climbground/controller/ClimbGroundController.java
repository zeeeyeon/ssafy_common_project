package com.project.backend.climbground.controller;

import com.project.backend.climbground.dto.requsetDTO.ClimbGroundAllRequestDTO;
import com.project.backend.climbground.dto.requsetDTO.ClimbGroundSearchRequestDTO;
import com.project.backend.climbground.dto.requsetDTO.MyClimbGroundRequestDTO;
import com.project.backend.climbground.dto.responseDTO.ClimbGroundAllResponseDTO;
import com.project.backend.climbground.dto.responseDTO.ClimbGroundDetailResponseDTO;
import com.project.backend.climbground.dto.responseDTO.MyClimGroundResponseDTO;
import com.project.backend.climbground.service.ClimbGroundServiceImpl;
import com.project.backend.common.ApiResponse;
import com.project.backend.common.ResponseType;
import lombok.RequiredArgsConstructor;

import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;


@RestController
@RequestMapping("/api/climbground")
@RequiredArgsConstructor
public class ClimbGroundController {


    private final ClimbGroundServiceImpl ClimbGroundService;

    // 클라이밍장 상세 조회
    @GetMapping("/detail/{climbground_id}")
    public ApiResponse<?> getCLimbDetail(@PathVariable Long climbground_id) {
        Optional<ClimbGroundDetailResponseDTO> climbGroundDetail = ClimbGroundService.findClimbGroundDetailById(climbground_id);

        if(climbGroundDetail.isEmpty()) {
            return ApiResponse.notFound();
        }
        return ApiResponse.success("data",climbGroundDetail);
    }

    // 클라이밍장 검색
    @GetMapping("/search")
    public ApiResponse<?> searchClimbGround(@ModelAttribute ClimbGroundSearchRequestDTO requestDTO) {
        List<ClimbGroundAllResponseDTO> climbGrounds = ClimbGroundService.searchClimbGroundByKeyword(requestDTO);

        if (climbGrounds.isEmpty()) {
            return ApiResponse.notMatchedClimbGround();
        }

        return ApiResponse.success("data",climbGrounds);
    }
    // 클라이밍장 리스트 조회 (거리별 정렬)
    @GetMapping("/all/user-location")
    public ApiResponse<?> getAllDisCLimbs(@ModelAttribute ClimbGroundAllRequestDTO requestDTO) {
        List<ClimbGroundAllResponseDTO> climbGrounds = ClimbGroundService.findAllClimbGround(requestDTO);
        if (climbGrounds.isEmpty()) {
            return ApiResponse.fail();
        }
//        return ApiResponse.success("data",climbGrounds);
        return ApiResponse.apiResponse(ResponseType.SUCCESS, "data", climbGrounds);
    }

    @GetMapping("/my-climbground")
    public ApiResponse<?> getMyClimbGround(@RequestBody MyClimbGroundRequestDTO requestDTO) {
        List<MyClimGroundResponseDTO> climbGrounds = ClimbGroundService.myClimbGroundWithIds(requestDTO);
        if (climbGrounds.isEmpty()) {
            return ApiResponse.apiResponse(ResponseType.NO_MATCHING_CLIMBING_GYM);
        }
        return ApiResponse.apiResponse(ResponseType.SUCCESS, "data", climbGrounds);
    }

}
