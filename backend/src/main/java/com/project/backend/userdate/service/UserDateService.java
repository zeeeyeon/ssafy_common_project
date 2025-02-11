package com.project.backend.userdate.service;

import com.project.backend.climbground.entity.ClimbGround;
import com.project.backend.climbground.repository.ClimbGroundRepository;
import com.project.backend.common.advice.exception.CustomException;
import com.project.backend.common.response.ResponseCode;
import com.project.backend.hold.dto.HoldColorLevelDto;
import com.project.backend.hold.dto.responseDTO.HoldResponseDTO;
import com.project.backend.hold.entity.HoldColorEnum;
import com.project.backend.hold.entity.HoldLevelEnum;
import com.project.backend.hold.repository.HoldRepository;
import com.project.backend.record.entity.ClimbingRecord;
import com.project.backend.user.entity.User;
import com.project.backend.user.repository.jpa.UserRepository;
import com.project.backend.userclimbground.dto.responseDTO.UnLockClimbGroundDetailResponseDTO;
import com.project.backend.userclimbground.entity.UserClimbGround;
import com.project.backend.userclimbground.entity.UserClimbGroundMedalEnum;
import com.project.backend.userclimbground.repository.UserClimbGroundRepository;
import com.project.backend.userclimbground.service.UserClimbGroundServiceImp;
import com.project.backend.userdate.dto.ClimbGroundWithDistance;
import com.project.backend.userdate.dto.MonthlyRecordDto;
import com.project.backend.userdate.dto.request.UserDateCheckAndAddLocationRequestDTO;
import com.project.backend.userdate.dto.request.UserDateCheckAndAddRequestDTO;
import com.project.backend.userdate.dto.response.*;
import com.project.backend.userdate.entity.UserDate;
import com.project.backend.userdate.repository.UserDateRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.time.*;
import java.util.*;
import java.util.stream.Collectors;

import static com.project.backend.common.response.ResponseCode.NOT_FOUND_CLIMB_GROUND_OR_USER;

@Service
@RequiredArgsConstructor
public class UserDateService {

    private final UserDateRepository userDateRepository;
    private final HoldRepository holdRepository;
    private final UserClimbGroundRepository userClimbGroundRepository;
    private final ClimbGroundRepository climbGroundRepository;
    private final UserRepository userRepository;
    private final UserClimbGroundServiceImp userClimbGroundServiceImp;

    public DailyClimbingRecordResponse getDailyRecord(LocalDate selectedDate, Long userId) {

        // baseEntity, LocalDateTime 으로 설정되어있어서
        LocalDateTime startOfDay = selectedDate.atStartOfDay();
        LocalDateTime endOfDay = selectedDate.atTime(LocalTime.MAX);

        // 해당 날짜 기록이 존재하는지 확인
        Optional<UserDate> userDate = userDateRepository.findByDateAndUserId(startOfDay, endOfDay, userId);
        if (!userDate.isPresent()) {
            throw new CustomException(NOT_FOUND_CLIMB_GROUND_OR_USER);
        }

        // 클라이밍장 이름
        String climbingGround = userDate.get().getUserClimbGround().getClimbGround().getName();

        // 해당 클라이밍장 방문 횟수
        int visitCount = userDateRepository.countVisits(startOfDay, endOfDay, userDate.get().getUserClimbGround().getClimbGround().getId());

        // 완등 횟수
        Set<ClimbingRecord> climbingRecords = userDate.get().getClimbingRecordList();
        int totalCount = climbingRecords.size();
        long successCount = climbingRecords.stream()
                .filter(ClimbingRecord::isSuccess)
                .count();

        // 완등률
        double completionRate = totalCount > 0 ? (double) successCount / totalCount * 100 : 0;

        // 클라이밍장 난이도
        // 클라이밍장 홀드 정보 조회
        Long climbingHoldGround = userDate.get().getUserClimbGround().getClimbGround().getId();
        List<HoldColorLevelDto> holdColorLevelInfo = holdRepository.findHoldColorLevelByClimbGroundId(climbingHoldGround);

        Map<HoldColorEnum, HoldLevelEnum> holdColorLevel = holdColorLevelInfo.stream()
                .sorted(Comparator.comparing(dto -> dto.getLevel().getValue()))
                .collect(Collectors.toMap(
                        HoldColorLevelDto::getColor,
                        HoldColorLevelDto::getLevel,
                        (existing, replacement) -> existing,
                        LinkedHashMap::new
                ));

        // 해당 난이도 완등률
        // 색상별 시도 횟수
        Map<HoldColorEnum, Long> colorAttempts = climbingRecords.stream()
                .collect(Collectors.groupingBy(
                        record -> record.getHold().getColor(),
                        Collectors.counting()
                ));

        // 색상별 성공 횟수
        Map<HoldColorEnum, Long> colorSuccesses = climbingRecords.stream()
                .filter(ClimbingRecord::isSuccess)
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

    @Cacheable(value = "monthlyRecords", key = "#userId + '_' + 'monthly_' + #selectedMonth")
    public MonthlyClimbingRecordResponse getMonthlyRecords(YearMonth selectedMonth, Long userId) {
        int year = selectedMonth.getYear();
        int month = selectedMonth.getMonthValue();

        List<MonthlyRecordDto> monthlyRecords = userDateRepository
                .findMonthlyRecords(year, month, userId);

        Map<Integer, MonthlyRecordDto> recordMap = totalCountRecordPerDay(monthlyRecords);

        int lastDay = YearMonth.of(year, month).lengthOfMonth();
        List<MonthlyClimbingRecordResponse.DayRecord> dayRecords = dayRecords(recordMap, lastDay);

        return new MonthlyClimbingRecordResponse(year, month, dayRecords);
    }

    // 날짜별 레코드 매핑
    private Map<Integer, MonthlyRecordDto> totalCountRecordPerDay(List<MonthlyRecordDto> monthlyRecords) {
        return monthlyRecords.stream()
                .collect(Collectors.toMap(
                        MonthlyRecordDto::getDay,
                        record -> record
                ));
    }

    // 월별 기록 리스트 생성
    private List<MonthlyClimbingRecordResponse.DayRecord> dayRecords(Map<Integer, MonthlyRecordDto> recordMap, int lastDay) {
        List<MonthlyClimbingRecordResponse.DayRecord> dayRecords = new ArrayList<>();
        for (int day = 1; day <= lastDay; day++) {
            MonthlyRecordDto record = recordMap.get(day);
            dayRecords.add(new MonthlyClimbingRecordResponse.DayRecord(
                    day,
                    record != null,
                    record != null ? record.getTotalCount() : 0
            ));
        }
        return dayRecords;
    }

    public ChallUnlockResponseDTO ChallUserDateCheckAndAdd(Long userId,UserDateCheckAndAddRequestDTO requestDTO) {
        ClimbGroundWithDistance climbGround = climbGroundRepository.findClimbGroundByIDAndDistance(requestDTO.getClimbGroundId(),requestDTO.getLatitude(), requestDTO.getLongitude());
        if (climbGround.getDistance() > 0.5){ // 500 미터 이상이면
            throw new CustomException(ResponseCode.NOT_FOUND_NEAR_CLIMB);
        }
        //  클라이밍장이 해금 되어 있는지 부터 체크
        UserClimbGround userClimbGround = CheckUserClimbGround(userId, requestDTO.getClimbGroundId());

        // userDate가 있는지 체크
        UserDateCheckAndAddResponseDTO userDateDTO= CheckAndAdd(userId,userClimbGround);

        // detail
        UnLockClimbGroundDetailResponseDTO detailResponseDTO = userClimbGroundServiceImp.getUnlockClimbGroundDetail(userId, requestDTO.getClimbGroundId());

        ChallUnlockResponseDTO responseDTO = new ChallUnlockResponseDTO(
                userDateDTO, detailResponseDTO
        );

        return responseDTO;
    }

    public UserDateCheckAndAddResponseDTO UserDateCheckAndAdd(UserDateCheckAndAddLocationRequestDTO requestDTO) {
        ClimbGroundWithDistance nearClimbGround = climbGroundRepository.findClimbGroundByDistance(requestDTO.getLatitude(), requestDTO.getLongitude());
        if (nearClimbGround.getDistance() > 0.5){ // 500 미터 이상이면
            throw new CustomException(ResponseCode.NOT_FOUND_NEAR_CLIMB);
        }
        //  클라이밍장이 해금 되어 있는지 부터 체크
        UserClimbGround userClimbGround = CheckUserClimbGround(requestDTO.getUserId(), nearClimbGround.getClimbGroundId());

        // userDate가 있는지 체크
        UserDateCheckAndAddResponseDTO responseDTO= CheckAndAdd(requestDTO.getUserId(),userClimbGround);

        return responseDTO;
    }

    // 클라이밍장 체크 해금여부 체크하는 코드
    private UserClimbGround CheckUserClimbGround(Long userId , Long climbGroundId) {
        Optional<UserClimbGround> userClimbGround = userClimbGroundRepository.findByUserIdAndClimbGroundId(userId, climbGroundId);
        if (userClimbGround.isPresent()) {
            return userClimbGround.get();
        }
        UserClimbGround newUserClimbGround = new UserClimbGround();
        ClimbGround climbGround = climbGroundRepository.findById(climbGroundId).orElseThrow(() -> new EntityNotFoundException("클라이밍장을 정보를 찾을 수 없습니다."));
        User user = userRepository.findById(userId).orElseThrow(() ->new EntityNotFoundException("일치하는 유저를 찾을 수 없습니다"));
        newUserClimbGround.setUser(user);
        newUserClimbGround.setClimbGround(climbGround);
        newUserClimbGround.setMedal(UserClimbGroundMedalEnum.NONE);
        userClimbGroundRepository.save(newUserClimbGround);

        return newUserClimbGround;
    }


    private UserDateCheckAndAddResponseDTO CheckAndAdd(Long userId,UserClimbGround userClimbGround) {

        // 현재일 구하기
        LocalDate date = LocalDate.now();
        ZoneId koreaZone = ZoneId.of("Asia/Seoul");
        LocalDateTime startOfDay = date.atStartOfDay(koreaZone).toLocalDateTime();
        LocalDateTime endOfDay = date.atTime(LocalTime.MAX).atZone(koreaZone).toLocalDateTime();

        Optional<UserDate> userDate =userDateRepository.findUserDateByUserAndClimbgroundAndDate(userId, userClimbGround.getClimbGround().getId(), startOfDay, endOfDay);

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
            UserDate newUserDate = new UserDate();
            newUserDate.setUserClimbGround(userClimbGround);
            List<HoldResponseDTO> holds = userClimbGround.getClimbGround().getHoldList().stream()
                    .map(hold -> new HoldResponseDTO(hold.getId(),hold.getLevel(),hold.getColor()))
                    .sorted(Comparator.comparing(HoldResponseDTO::getLevel))
                    .collect(Collectors.toList());
            responseDTO.setName(userClimbGround.getClimbGround().getName());
            responseDTO.setHolds(holds);
            responseDTO.setNewlyCreated(true);
            userDateRepository.save(newUserDate); // 다넣었으면 저장
            responseDTO.setUserDateId(newUserDate.getId());

        }

        return responseDTO;
    }


}
