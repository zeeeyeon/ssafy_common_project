package com.project.backend.climbground.service;

import com.project.backend.climbground.dto.requsetDTO.ClimbGroundAllRequestDTO;
import com.project.backend.climbground.dto.requsetDTO.ClimbGroundSearchRequestDTO;
import com.project.backend.climbground.dto.requsetDTO.LockClimbGroundAllRequsetDTO;
import com.project.backend.climbground.dto.requsetDTO.MyClimbGroundRequestDTO;
import com.project.backend.climbground.dto.responseDTO.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

public interface ClimbGroundService {

    // 클라이밍장 전체조회
    List<ClimbGroundAllResponseDTO> findAllClimbGround(BigDecimal latitude, BigDecimal longitude);

    // 클라이밍장 상세페이지
    Optional<ClimbGroundDetailResponseDTO> findClimbGroundDetailById(Long climbGroundId);

    // 클라이밍장 검색 조회
    List<ClimbGroundAllResponseDTO> searchClimbGroundByKeyword(String keyword, BigDecimal latitude, BigDecimal longitude);

    // 내가 방문한 클라이밍장 리스트 조회
    List<MyClimGroundResponseDTO> myClimbGroundWithIds(MyClimbGroundRequestDTO requestDTO);

    List<LockClimbGroundAllResponseDTO> findAllLockClimbGround(Long userId ,BigDecimal latitude, BigDecimal longitude);

    List<LockClimbGroundAllResponseDTO> findAllLockClimbGroundLimitFive(Long userId ,BigDecimal latitude, BigDecimal longitude);
}
