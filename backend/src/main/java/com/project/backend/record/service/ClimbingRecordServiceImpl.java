package com.project.backend.record.service;

import com.project.backend.hold.entity.Hold;
import com.project.backend.hold.repository.HoldRepository;
import com.project.backend.record.dto.requestDTO.RecordSaveRequestDTO;
import com.project.backend.record.entity.ClimbingRecord;
import com.project.backend.record.repository.ClimbingRecordRepository;
import com.project.backend.user.entity.User;
import com.project.backend.user.repository.jpa.UserRepository;
import com.project.backend.userdate.entity.UserDate;
import com.project.backend.userdate.repository.UserDateRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;

import java.util.Optional;

public class ClimbingRecordServiceImpl implements ClimbingRecordService {

    HoldRepository holdRepository;
    UserRepository userRepository;
    UserDateRepository userDateRepository;
    ClimbingRecordRepository climbingRecordRepository;

    @Override
    @Transactional
    public Optional<ClimbingRecord> saveRecord(RecordSaveRequestDTO requestDTO){
        ClimbingRecord newClimbingRecord = new ClimbingRecord();
        // Hold, User, UserDate 객체를 데이터베이스에서 찾고, 존재하지 않을 경우 예외 발생
        Hold hold = holdRepository.findById(requestDTO.getHoldId())
                .orElseThrow(() -> new EntityNotFoundException("Hold not found with id: " + requestDTO.getHoldId()));
        User user = userRepository.findById(requestDTO.getUserId())
                .orElseThrow(() -> new EntityNotFoundException("User not found with id: " + requestDTO.getUserId()));
        UserDate userDate = userDateRepository.findById(requestDTO.getUserDateId())
                .orElseThrow(() -> new EntityNotFoundException("UserDate not found with id: " + requestDTO.getUserDateId()));
        newClimbingRecord.setSuccess(requestDTO.getIsSuccess());
        newClimbingRecord.setHold(hold);
        newClimbingRecord.setUser(user);
        newClimbingRecord.setUserDate(userDate);
//        recordRepository.save( (com.project.backend.record.entity.Record) newRecord);

        return Optional.of(newClimbingRecord);

    };
}
