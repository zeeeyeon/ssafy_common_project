package com.project.backend.userclimbground.service;

import com.project.backend.common.ResponseType;
import com.project.backend.userclimbground.dto.requestDTO.UnlockClimbGroundRequsetDTO;
import com.project.backend.userclimbground.dto.requestDTO.ClimbRecordRequestDTO;
import com.project.backend.userclimbground.dto.responseDTO.ClimbRecordResponseDTO;

public interface UserClimbGroundService {

    ClimbRecordResponseDTO getUserClimbRecordYear(ClimbRecordRequestDTO requestDTO);

    ClimbRecordResponseDTO getUserClimbRecordMonth(ClimbRecordRequestDTO requestDTO);

    ClimbRecordResponseDTO getUserClimbRecordWeek(ClimbRecordRequestDTO requestDTO);

    ClimbRecordResponseDTO getUserClimbRecordDay(ClimbRecordRequestDTO requestDTO);

    // 클라이밍장 해금 요청
    ResponseType saveUnlockClimbGround(UnlockClimbGroundRequsetDTO requestDTO);
}
