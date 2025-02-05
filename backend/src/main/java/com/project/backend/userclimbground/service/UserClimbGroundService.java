package com.project.backend.userclimbground.service;

import com.project.backend.common.ResponseType;
import com.project.backend.common.response.ResponseCode;
import com.project.backend.userclimbground.dto.requestDTO.ClimbGroundRecordRequestDTO;
import com.project.backend.userclimbground.dto.requestDTO.UnlockClimbGroundRequsetDTO;
import com.project.backend.userclimbground.dto.requestDTO.ClimbRecordRequestDTO;
import com.project.backend.userclimbground.dto.responseDTO.ClimbGroundRecordResponseDTO;
import com.project.backend.userclimbground.dto.responseDTO.ClimbRecordResponseDTO;

import java.time.LocalDate;

public interface UserClimbGroundService {

    ClimbRecordResponseDTO getUserClimbRecordYear(Long userId , LocalDate date);

    ClimbRecordResponseDTO getUserClimbRecordMonth(Long userId , LocalDate date);

    ClimbRecordResponseDTO getUserClimbRecordWeek(Long userId , LocalDate date);

    ClimbRecordResponseDTO getUserClimbRecordDay(Long userId , LocalDate date);

    // 클라이밍장 해금 요청
    ResponseCode saveUnlockClimbGround(UnlockClimbGroundRequsetDTO requestDTO);

    // 클라이밍장별 통계(년별)
    ClimbGroundRecordResponseDTO getUserClimbGroundRecordYear(Long userId , Long climbGroundId,LocalDate date);

    // 클라이밍장별 통계(월별)
    ClimbGroundRecordResponseDTO getUserClimbGroundRecordMonth(Long userId , Long climbGroundId,LocalDate date);

    // 클라이밍장별 통계(주별)
    ClimbGroundRecordResponseDTO getUserClimbGroundRecordWeek(Long userId , Long climbGroundId,LocalDate date);

    // 클라이밍장별 통계(일별)
    ClimbGroundRecordResponseDTO getUserClimbGroundRecordDay(Long userId , Long climbGroundId,LocalDate date);

}
