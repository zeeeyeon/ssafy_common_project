package com.project.backend.record.service;

import com.project.backend.common.advice.exception.CustomException;
import com.project.backend.common.response.ResponseCode;
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
import lombok.RequiredArgsConstructor;
import org.springframework.cache.CacheManager;
import org.springframework.stereotype.Service;

import java.time.YearMonth;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ClimbingRecordServiceImpl implements ClimbingRecordService {

    private final HoldRepository holdRepository;
    private final UserRepository userRepository;
    private final UserDateRepository userDateRepository;
    private final ClimbingRecordRepository climbingRecordRepository;
    private final CacheManager redisCacheManager;

    @Override
    @Transactional
    public Optional<ClimbingRecord> saveRecord(Long userId ,RecordSaveRequestDTO requestDTO){
        ClimbingRecord newClimbingRecord = new ClimbingRecord();
        // Hold, User, UserDate 객체를 데이터베이스에서 찾고, 존재하지 않을 경우 예외 발생
        Hold hold = holdRepository.findById(requestDTO.getHoldId())
                .orElseThrow(() -> new CustomException(ResponseCode.BAD_REQUEST));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found with id: " + userId));
        UserDate userDate = userDateRepository.findById(requestDTO.getUserDateId())
                .orElseThrow(() -> new EntityNotFoundException("UserDate not found with id: " + requestDTO.getUserDateId()));
        newClimbingRecord.setSuccess(requestDTO.getIsSuccess());
        newClimbingRecord.setHold(hold);
        newClimbingRecord.setUser(user);
        newClimbingRecord.setUserDate(userDate);
        climbingRecordRepository.save(newClimbingRecord);

        // 캐싱처리
//        String cacheKey = requestDTO.getUserId() + "_monthly_" + YearMonth.from(userDate.getCreatedAt());
//        Optional.ofNullable(redisCacheManager.getCache("monthlyRecords"))
//                .ifPresent(cache -> cache.evictIfPresent(cacheKey));

        return Optional.of(newClimbingRecord);

    };
}
