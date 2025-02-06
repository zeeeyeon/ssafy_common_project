package com.project.backend.record.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.project.backend.record.entity.ClimbingRecord;

public interface ClimbingRecordRepository extends JpaRepository<ClimbingRecord, Long> {
}
