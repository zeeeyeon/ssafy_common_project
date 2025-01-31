package com.project.backend.climbground.controller;

import com.project.backend.climbground.dto.responseDTO.ClimbGroundAllResponseDTO;
import com.project.backend.climbground.dto.responseDTO.ClimbGroundDetailResponseDTO;
import com.project.backend.climbground.service.ClimbGroundServiceImpl;
import com.project.backend.common.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;


@RestController
@RequestMapping("/api/climbground")
public class ClimbGroundController {

    @Autowired
    private ClimbGroundServiceImpl ClimbGroundService;

    // 클라이밍장 상세 조회
    @GetMapping("/detail/{climbground_id}")
    public ApiResponse<?> getCLimbDetail(@PathVariable("climbground_id") Long climbground_id) {
        Optional<ClimbGroundDetailResponseDTO> climbGroundDetail = ClimbGroundService.findClimbGroundDetailById(climbground_id);

        if(climbGroundDetail.isPresent()) {

        }

    }

    // 클라이밍장 검색
    @GetMapping("/search")
    public ApiResponse<?> searchClimbGround(@RequestParam("keyword") String keyword,@RequestParam("latitude")BigDecimal latitude, @RequestParam("longitude")BigDecimal longitude) {
        List<ClimbGroundAllResponseDTO> climbGrounds = ClimbGroundService.searchClimbGroundByKeyword(keyword, latitude, longitude);

        if (climbGrounds.isEmpty()) {
            return ApiResponse.notMatchedClimbGround();
        }

        return ApiResponse.success("data",climbGrounds);
    }
    // 클라이밍장 리스트 조회 (거리별 정렬)
    @GetMapping("/all/user-location")
    public ApiResponse<?> getAllDisCLimbs(@RequestParam("latitude")BigDecimal latitude, @RequestParam("longitude")BigDecimal longitude) {
        List<ClimbGroundAllResponseDTO> climbGrounds = ClimbGroundService.findAllClimbGround(latitude,longitude);
        if (climbGrounds.isEmpty()) {
            return ApiResponse.fail();
        }
        return ApiResponse.success("data",climbGrounds);
    }
}
