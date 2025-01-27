package com.project.backend.climb.repository;

import com.project.backend.climb.entity.Climb;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ClimbRepository extends JpaRepository<Climb, Long> {
}
