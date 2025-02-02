package com.project.backend.climbground.service;

import com.project.backend.climbground.dto.requsetDTO.ClimbGroundAllRequestDTO;
import com.project.backend.climbground.dto.requsetDTO.ClimbGroundSearchRequestDTO;
import com.project.backend.climbground.dto.responseDTO.ClimbGroundAllResponseDTO;
import com.project.backend.climbground.dto.responseDTO.ClimbGroundDetailResponseDTO;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

public interface ClimbGroundService {

    // 클라이밍장 전체조회
    List<ClimbGroundAllResponseDTO> findAllClimbGround(ClimbGroundAllRequestDTO requestDTO);

    // 클라이밍장 상세페이지
    Optional<ClimbGroundDetailResponseDTO> findClimbGroundDetailById(Long climbground_id);

    // 클라이밍장 검색 조회
    List<ClimbGroundAllResponseDTO> searchClimbGroundByKeyword(ClimbGroundSearchRequestDTO requestDTO);

}
