package com.project.backend.userclimbground.service;

import com.project.backend.common.ResponseType;
import com.project.backend.common.response.ResponseCode;
import com.project.backend.userclimbground.dto.requestDTO.ClimbGroundRecordRequestDTO;
import com.project.backend.userclimbground.dto.requestDTO.UnlockClimbGroundRequestDTO;
import com.project.backend.userclimbground.dto.requestDTO.ClimbRecordRequestDTO;
import com.project.backend.userclimbground.dto.responseDTO.ClimbGroundRecordResponseDTO;
import com.project.backend.userclimbground.dto.responseDTO.ClimbRecordResponseDTO;
import com.project.backend.userclimbground.dto.responseDTO.UnLockClimbGroundDetailResponseDTO;

import java.time.LocalDate;

public interface UserClimbGroundService {

    ClimbRecordResponseDTO getUserClimbRecordYear(Long userId , LocalDate date);

    ClimbRecordResponseDTO getUserClimbRecordMonth(Long userId , LocalDate date);

    ClimbRecordResponseDTO getUserClimbRecordWeek(Long userId , LocalDate date);

    ClimbRecordResponseDTO getUserClimbRecordDay(Long userId , LocalDate date);

    // 클라이밍장 해금 요청
    ResponseCode saveUnlockClimbGround(Long userId, Long climbGroundId);

    // 클라이밍장별 통계(년별)
    ClimbGroundRecordResponseDTO getUserClimbGroundRecordYear(Long userId , Long climbGroundId,LocalDate date);

    // 클라이밍장별 통계(월별)
    ClimbGroundRecordResponseDTO getUserClimbGroundRecordMonth(Long userId , Long climbGroundId,LocalDate date);

    // 클라이밍장별 통계(주별)
    ClimbGroundRecordResponseDTO getUserClimbGroundRecordWeek(Long userId , Long climbGroundId,LocalDate date);

    // 클라이밍장별 통계(일별)
    ClimbGroundRecordResponseDTO getUserClimbGroundRecordDay(Long userId , Long climbGroundId,LocalDate date);

    // 해금된 클라이밍장 상세 페이지
    UnLockClimbGroundDetailResponseDTO getUnlockClimbGroundDetail(Long userId , Long climbGroundId);
}
