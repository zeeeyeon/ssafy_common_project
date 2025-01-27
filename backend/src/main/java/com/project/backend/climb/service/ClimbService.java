package com.project.backend.climb.service;

import com.project.backend.climb.entity.Climb;

import java.util.List;
import java.util.Optional;

public interface ClimbService {

    List<Climb> findAllClimb();

    Optional<Climb> findClimbById(Long id);
}
