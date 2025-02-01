package com.project.backend.userclimbground.service;

import com.project.backend.userclimbground.dto.requestDTO.ClimbRecordRequestDTO;
import com.project.backend.userclimbground.dto.responseDTO.ClimbRecordResponseDTO;

public interface UserClimbGroundService {

    ClimbRecordResponseDTO getUserClimbRecordYear(ClimbRecordRequestDTO requestDTO);

    ClimbRecordResponseDTO getUserClimbRecordMonth(ClimbRecordRequestDTO requestDTO);
}
