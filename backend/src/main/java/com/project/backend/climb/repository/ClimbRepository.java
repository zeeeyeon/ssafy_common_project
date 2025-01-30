package com.project.backend.climb.center.repository;

import com.project.backend.climb.center.entity.Climb;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ClimbRepository extends JpaRepository<Climb, Long> {
}
