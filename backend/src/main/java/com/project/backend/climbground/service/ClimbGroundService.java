package com.project.backend.climbground.service;

import com.project.backend.climbground.entity.ClimbGround;

import java.util.List;
import java.util.Optional;

public interface ClimbGroundService {

    List<ClimbGround> findAllClimbGround();

    Optional<ClimbGround> findClimbGroundById(Long id);
}
