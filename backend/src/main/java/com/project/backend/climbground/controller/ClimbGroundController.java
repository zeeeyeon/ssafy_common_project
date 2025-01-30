package com.project.backend.climbground.controller;

import com.project.backend.climbground.dto.requsetDTO.ClimbGroundDetailRequestDTO;
import com.project.backend.climbground.dto.responseDTO.ClimbGroundAllResponseDTO;
import com.project.backend.climbground.dto.responseDTO.ClimbGroundDetailResponseDTO;
import com.project.backend.climbground.repository.ClimbGroundRepository;
import com.project.backend.climbground.service.ClimbGroundService;
import com.project.backend.climbground.service.ClimbGroundServiceImpl;
import com.project.backend.hold.dto.responseDTO.HoldResponseDTO;
import com.project.backend.info.dto.responseDTO.InfoResponseDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Comparator;
import java.util.List;
import java.util.TreeSet;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/climbground")
public class ClimbGroundController {

    @Autowired
    private ClimbGroundServiceImpl ClimbGroundService;

    // 클라이밍장 리스트 조회
//    @GetMapping("/all/user-location")
//    public List<ClimbGroundAllResponseDTO> getALlCLimbs() {
//        return ClimbGroundService.findAllClimbGround();
//    }

    @GetMapping("/all/user-location")
    public ResponseEntity<?> getAllCLimbs() {
        List<ClimbGroundAllResponseDTO> climbGrounds = ClimbGroundService.findAllClimbGround();
        if (climbGrounds.isEmpty()) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(climbGrounds);
    }

    // 클라이밍장 상세 조회
    @GetMapping("/detail/{climbground_id}")
    public ResponseEntity<?> getCLimbDetail(@PathVariable("climbground_id") Long climbground_id) {
        return ClimbGroundService.findClimbGroundDetailById(climbground_id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build()); // 찾는거 없으면 404에러
    }

    // 클라이밍장 검색
    @GetMapping("/search")
    public ResponseEntity<?> searchClimbGround(@RequestParam("keyword") String keyword) {
        List<ClimbGroundAllResponseDTO> resultList = ClimbGroundService.searchClimbGroundByKeyword(keyword);

        if (resultList.isEmpty()) {
            return ResponseEntity.noContent().build();
        }

        return ResponseEntity.ok(resultList);
    }
}
