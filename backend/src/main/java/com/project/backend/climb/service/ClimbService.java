package com.project.backend.climb.center.service;

import com.project.backend.climb.center.entity.Climb;

import java.util.List;
import java.util.Optional;

public interface ClimbService {

    List<Climb> findAllClimb();

    Optional<Climb> findClimbById(Long id);
}
