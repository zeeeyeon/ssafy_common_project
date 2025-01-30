package com.project.backend.climb.center.controller;

import com.project.backend.climb.center.dto.responseDTO.ClimbResponseDTO;
import com.project.backend.climb.center.service.ClimbServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/climb")
public class ClimbController {

    @Autowired
    private ClimbServiceImpl ClimbServiceImpl;

    // 클라이밍장 리스트 조회
    @GetMapping("/all/user-location")
    public List<ClimbResponseDTO> getALlCLimbs() {
        return ClimbServiceImpl.findAllClimb().stream()
                .map(climb -> new ClimbResponseDTO(climb.getId(), climb.getName(), climb.getImage(), climb.getAddress(), climb.getOpen(), climb.getNumber(), climb.getSns_url()))
                .collect(Collectors.toList());
    }

}
