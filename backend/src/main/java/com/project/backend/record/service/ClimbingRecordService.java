package com.project.backend.record.service;

import com.project.backend.record.dto.requestDTO.RecordSaveRequestDTO;
import com.project.backend.record.entity.ClimbingRecord;

import java.util.Optional;

public interface ClimbingRecordService {

    Optional<ClimbingRecord> saveRecord(Long userId, RecordSaveRequestDTO requestDTO);
}
