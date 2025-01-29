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
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
    @GetMapping("/all/user-location")
    public List<ClimbGroundAllResponseDTO> getALlCLimbs() {
        return ClimbGroundService.findAllClimbGround();
    }

    // 클라이밍장 상세 조회
    @GetMapping("/detail/{climbground_id}")
    public ResponseEntity<?> getCLimbDetail(@PathVariable("climbground_id") Long climbground_id) {
        return ClimbGroundService.findClimbGroundDetailById(climbground_id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build()); // 찾는거 없으면 404에러
    }

}
