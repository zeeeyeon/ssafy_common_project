package com.project.backend.climbground.service;

import com.project.backend.climbground.dto.responseDTO.ClimbGroundAllResponseDTO;
import com.project.backend.climbground.dto.responseDTO.ClimbGroundDetailResponseDTO;
import java.util.List;
import java.util.Optional;

public interface ClimbGroundService {

    List<ClimbGroundAllResponseDTO> findAllClimbGround();

    Optional<ClimbGroundDetailResponseDTO> findClimbGroundDetailById(Long id);
}
