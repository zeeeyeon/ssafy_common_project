package com.project.backend.climbground.controller;

import com.project.backend.climbground.dto.responseDTO.ClimbGroundAllResponseDTO;
import com.project.backend.climbground.service.ClimbGroundServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.math.BigDecimal;
import java.util.List;


@RestController
@RequestMapping("/api/climbground")
public class ClimbGroundController {

    @Autowired
    private ClimbGroundServiceImpl ClimbGroundService;

    // 클라이밍장 상세 조회
    @GetMapping("/detail/{climbground_id}")
    public ResponseEntity<?> getCLimbDetail(@PathVariable("climbground_id") Long climbground_id) {
        return ClimbGroundService.findClimbGroundDetailById(climbground_id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build()); // 찾는거 없으면 404에러
    }

    // 클라이밍장 검색
    @GetMapping("/search")
    public ResponseEntity<?> searchClimbGround(@RequestParam("keyword") String keyword,@RequestParam("latitude")BigDecimal latitude, @RequestParam("longitude")BigDecimal longitude) {
        List<ClimbGroundAllResponseDTO> resultList = ClimbGroundService.searchClimbGroundByKeyword(keyword, latitude, longitude);

        if (resultList.isEmpty()) {
            return ResponseEntity.noContent().build();
        }

        return ResponseEntity.ok(resultList);
    }

    // 클라이밍장 리스트 조회 (거리별 정렬)
    @GetMapping("/all/user-location")
    public ResponseEntity<?> getAllDisCLimbs(@RequestParam("latitude")BigDecimal latitude, @RequestParam("longitude")BigDecimal longitude) {
        List<ClimbGroundAllResponseDTO> climbGrounds = ClimbGroundService.findAllClimbGround(latitude,longitude);
        if (climbGrounds.isEmpty()) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(climbGrounds);
    }
}
