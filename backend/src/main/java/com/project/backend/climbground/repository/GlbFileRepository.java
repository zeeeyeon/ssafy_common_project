package com.project.backend.climbground.repository;

import com.project.backend.climbground.entity.GlbFile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

public interface GlbFileRepository extends JpaRepository<GlbFile, Long> {
}
