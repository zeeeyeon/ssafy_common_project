package com.project.backend.userdate.service;

import com.project.backend.hold.dto.HoldColorLevelDto;
import com.project.backend.hold.dto.responseDTO.HoldResponseDTO;
import com.project.backend.hold.entity.HoldColorEnum;
import com.project.backend.hold.entity.HoldLevelEnum;
import com.project.backend.hold.repository.HoldRepository;
import com.project.backend.record.entity.Record;
import com.project.backend.userclimbground.entity.UserClimbGround;
import com.project.backend.userclimbground.repository.UserClimbGroundRepository;
import com.project.backend.userdate.dto.MonthlyRecordDto;
import com.project.backend.userdate.dto.request.UserDateCheckAndAddRequestDTO;
import com.project.backend.userdate.dto.response.DailyClimbingRecordResponse;
import com.project.backend.userdate.dto.response.MonthlyClimbingRecordResponse;
import com.project.backend.userdate.dto.response.UserDateCheckAndAddResponseDTO;
import com.project.backend.userdate.entity.UserDate;
import com.project.backend.userdate.repository.UserDateRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.YearMonth;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserDateService {

    private final UserDateRepository userDateRepository;
    private final HoldRepository holdRepository;
    private final UserClimbGroundRepository userClimbGroundRepository;

    public DailyClimbingRecordResponse getDailyRecord(LocalDate selectedDate, Long userId) {

        // baseEntity, LocalDateTime 으로 설정되어있어서
        LocalDateTime startOfDay = selectedDate.atStartOfDay();
        LocalDateTime endOfDay = selectedDate.atTime(LocalTime.MAX);

        // 해당 날짜 기록이 존재하는지 확인
        UserDate userDate = userDateRepository.findByDateAndUserId(startOfDay, endOfDay, userId)
                .orElseThrow(() -> new EntityNotFoundException("해당 날짜의 기록이 존재하지 않습니다."));

        // 클라이밍장 이름
        String climbingGround = userDate.getUserClimbGround().getClimbGround().getName();

        // 해당 클라이밍장 방문 횟수
        int visitCount = userDateRepository.countVisits(startOfDay, endOfDay, userDate.getUserClimbGround().getId());

        // 완등 횟수
        Set<Record> records = userDate.getRecordList();
        int totalCount = records.size();
        long successCount = records.stream()
                .filter(Record::isSuccess)
                .count();

        // 완등률
        double completionRate = totalCount > 0 ? (double) successCount / totalCount * 100 : 0;

        // 클라이밍장 난이도
        // 클라이밍장 홀드 정보 조회
        Long climbingHoldGround = userDate.getUserClimbGround().getClimbGround().getId();
        List<HoldColorLevelDto> holdColorLevelInfo = holdRepository.findHoldColorLevelByClimbGroundId(climbingHoldGround);

        Map<HoldColorEnum, HoldLevelEnum> holdColorLevel = holdColorLevelInfo.stream()
                .collect(Collectors.toMap(
                        HoldColorLevelDto::getColor,
                        HoldColorLevelDto::getLevel,
                        (existing, replacement) -> existing
                ));

        // 해당 난이도 완등률
        // 색상별 시도 횟수
        Map<HoldColorEnum, Long> colorAttempts = records.stream()
                .collect(Collectors.groupingBy(
                        record -> record.getHold().getColor(),
                        Collectors.counting()
                ));

        // 색상별 성공 횟수
        Map<HoldColorEnum, Long> colorSuccesses = records.stream()
                .filter(Record::isSuccess)
                .collect(Collectors.groupingBy(
                        record -> record.getHold().getColor(),
                        Collectors.counting()
                ));


        return DailyClimbingRecordResponse.builder()
                .climbGroundName(climbingGround)
                .visitCount(visitCount)
                .successCount(successCount)
                .completionRate(completionRate)
                .holdColorLevel(holdColorLevel)
                .colorAttempts(colorAttempts)
                .colorSuccesses(colorSuccesses)
                .build();
    }


    public MonthlyClimbingRecordResponse getMonthlyRecords(YearMonth selectedMonth, Long userId) {
        int year = selectedMonth.getYear();
        int month = selectedMonth.getMonthValue();

        List<MonthlyRecordDto> monthlyRecords = userDateRepository
                .findMonthlyRecords(year, month, userId);

        // <일자, 각 날짜별 시도 횟수>
        Map<Integer, MonthlyRecordDto> recordMap = monthlyRecords.stream()
                .collect(Collectors.toMap(
                        MonthlyRecordDto::getDay,
                        record -> record
                ));

        // 마지막 날 계산
        YearMonth yearMonth = YearMonth.of(year, month);
        int lastDay = yearMonth.lengthOfMonth();

        // DayRecord 생성
        List<MonthlyClimbingRecordResponse.DayRecord> dayRecords = new ArrayList<>();
        for (int day = 1; day <= lastDay; day++) {
            MonthlyRecordDto record = recordMap.get(day);
            dayRecords.add(new MonthlyClimbingRecordResponse.DayRecord(
                    day,
                    record != null,
                    record != null ? record.getTotalCount() : 0
            ));
        }

        return MonthlyClimbingRecordResponse.builder()
                .year(year)
                .month(month)
                .records(dayRecords)
                .build();
    }

    public UserDateCheckAndAddResponseDTO UserDateCheckAndAdd(UserDateCheckAndAddRequestDTO requestDTO) {
        LocalDateTime startOfDay = requestDTO.getDate().atStartOfDay();
        LocalDateTime endOfDay = requestDTO.getDate().atTime(LocalTime.MAX);

        Optional<UserDate> userDate =userDateRepository.findUserDateByUserAndClimbgroundAndDate(requestDTO.getUserId(), requestDTO.getClimbGroundId(), startOfDay, endOfDay);
        UserDateCheckAndAddResponseDTO responseDTO = new UserDateCheckAndAddResponseDTO();
        if (userDate.isPresent()) { // 데이터가 있으면
            responseDTO.setUserDateId(userDate.get().getId());
            responseDTO.setName(userDate.get().getUserClimbGround().getClimbGround().getName());
            List<HoldResponseDTO> holds = userDate.get().getUserClimbGround().getClimbGround().getHoldList().stream()
                    .map(hold -> new HoldResponseDTO(hold.getId(),hold.getLevel(),hold.getColor()))
                    .sorted(Comparator.comparing(HoldResponseDTO::getLevel))
                    .collect(Collectors.toList());
            responseDTO.setHolds(holds);
            responseDTO.setNewlyCreated(false);
        } else{
            UserClimbGround userClimbGround = userClimbGroundRepository.findUserClimbGroundByUserIDAndClimbGroundID(requestDTO.getUserId(),requestDTO.getClimbGroundId())
                    .orElseThrow(() -> new EntityNotFoundException("아직 해금되지 않은 클라이밍장 입니다"));
            UserDate newUserDate = new UserDate();
            newUserDate.setUserClimbGround(userClimbGround);
            List<HoldResponseDTO> holds = userClimbGround.getClimbGround().getHoldList().stream()
                    .map(hold -> new HoldResponseDTO(hold.getId(),hold.getLevel(),hold.getColor()))
                    .sorted(Comparator.comparing(HoldResponseDTO::getLevel))
                    .collect(Collectors.toList());
            responseDTO.setHolds(holds);
            responseDTO.setNewlyCreated(true);
            userDateRepository.save(newUserDate); // 다넣었으면 저장

        }

        return responseDTO;
    }
}
