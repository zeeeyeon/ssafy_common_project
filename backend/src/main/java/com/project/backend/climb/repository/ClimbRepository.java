package com.project.backend.climb.repository;

import com.project.backend.climb.entity.Climb;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ClimbRepository extends JpaRepository<Climb, Long> {
}
