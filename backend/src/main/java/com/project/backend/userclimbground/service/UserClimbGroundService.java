package com.project.backend.userclimbground.service;

import com.project.backend.common.ResponseType;
import com.project.backend.common.response.ResponseCode;
import com.project.backend.userclimbground.dto.requestDTO.ClimbGroundRecordRequestDTO;
import com.project.backend.userclimbground.dto.requestDTO.UnlockClimbGroundRequsetDTO;
import com.project.backend.userclimbground.dto.requestDTO.ClimbRecordRequestDTO;
import com.project.backend.userclimbground.dto.responseDTO.ClimbGroundRecordResponseDTO;
import com.project.backend.userclimbground.dto.responseDTO.ClimbRecordResponseDTO;

public interface UserClimbGroundService {

    ClimbRecordResponseDTO getUserClimbRecordYear(ClimbRecordRequestDTO requestDTO);

    ClimbRecordResponseDTO getUserClimbRecordMonth(ClimbRecordRequestDTO requestDTO);

    ClimbRecordResponseDTO getUserClimbRecordWeek(ClimbRecordRequestDTO requestDTO);

    ClimbRecordResponseDTO getUserClimbRecordDay(ClimbRecordRequestDTO requestDTO);

    // 클라이밍장 해금 요청
    ResponseCode saveUnlockClimbGround(UnlockClimbGroundRequsetDTO requestDTO);

    // 클라이밍장별 통계(년별)
    ClimbGroundRecordResponseDTO getUserClimbGroundRecordYear(ClimbGroundRecordRequestDTO requestDTO);

    // 클라이밍장별 통계(월별)
    ClimbGroundRecordResponseDTO getUserClimbGroundRecordMonth(ClimbGroundRecordRequestDTO requestDTO);

    // 클라이밍장별 통계(주별)
    ClimbGroundRecordResponseDTO getUserClimbGroundRecordWeek(ClimbGroundRecordRequestDTO requestDTO);

    // 클라이밍장별 통계(일별)
    ClimbGroundRecordResponseDTO getUserClimbGroundRecordDay(ClimbGroundRecordRequestDTO requestDTO);

}
