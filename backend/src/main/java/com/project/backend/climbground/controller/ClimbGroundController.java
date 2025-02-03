package com.project.backend.climbground.controller;

import com.project.backend.climbground.dto.responseDTO.ClimbGroundAllResponseDTO;
import com.project.backend.climbground.service.ClimbGroundServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/climbground")
public class ClimbGroundController {

    @Autowired
    private ClimbGroundServiceImpl ClimbGroundService;

    // 클라이밍장 리스트 조회
    @GetMapping("/all/user-location")
    public List<ClimbGroundAllResponseDTO> getALlCLimbs() {
        return ClimbGroundService.findAllClimbGround().stream()
                .map(climb -> new ClimbGroundAllResponseDTO(climb.getId(), climb.getName(), climb.getImage(), climb.getAddress()))
                .collect(Collectors.toList());
    }

    // 클라이밍장 상세 조회
//    @GetMapping("/detail/{climb_id}")
//    public ResponseEntity<ClimbGroundDetailRequestDTO> getCLimbDetail(@PathVariable("climb_id") String climb_id) {
//
//    }


//    public List<ClimbResponseDTO> getAllClimbs() {
//        return ClimbService.findAllClimb().stream()
//                .map(climb -> {
//                    List<HoldResponseDTO> holds = climb.getHoldList().stream()
//                            .sorted(Comparator.comparing(hold -> hold.getLevel().getValue()))
//                            .map(hold -> new HoldResponseDTO(hold.getId(), hold.getLevel(), hold.getColor()))
//                            .collect(Collectors.toList());
//
//                    return new ClimbResponseDTO(
//                            climb.getId(),
//                            climb.getName(),
//                            climb.getImage(),
//                            climb.getAddress(),
//                            climb.getOpen(),
//                            climb.getNumber(),
//                            climb.getSns_url()
//                    );
//                })
//                .collect(Collectors.toList());
//    }

}
