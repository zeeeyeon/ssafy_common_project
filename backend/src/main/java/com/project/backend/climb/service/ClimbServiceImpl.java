package com.project.backend.climb.center.service;

import com.project.backend.climb.center.entity.Climb;
import com.project.backend.climb.center.repository.ClimbRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ClimbServiceImpl implements ClimbService{

    @Autowired
    private ClimbRepository climbRepository;

    @Override
    public List<Climb> findAllClimb() {
        return climbRepository.findAll();
    }

    @Override
    public Optional<Climb> findClimbById(Long id) {
        return climbRepository.findById(id);
    }
}
