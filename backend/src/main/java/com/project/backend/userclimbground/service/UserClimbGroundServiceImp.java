package com.project.backend.userclimbground.service;

import com.project.backend.climbground.entity.ClimbGround;
import com.project.backend.climbground.repository.ClimbGroundRepository;
import com.project.backend.common.advice.exception.CustomException;
import com.project.backend.common.response.ResponseCode;
import com.project.backend.user.entity.User;
import com.project.backend.user.repository.jpa.UserRepository;
import com.project.backend.userclimbground.dto.requestDTO.UnlockClimbGroundRequestDTO;
import com.project.backend.hold.entity.HoldColorEnum;
import com.project.backend.record.entity.ClimbingRecord;
import com.project.backend.userclimbground.dto.responseDTO.*;
import com.project.backend.userclimbground.entity.UserClimbGround;
import com.project.backend.userclimbground.entity.UserClimbGroundMedalEnum;
import com.project.backend.userclimbground.repository.UserClimbGroundRepository;
import com.project.backend.userdate.entity.UserDate;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;


import java.time.LocalDate;
import java.time.temporal.ChronoField;
import java.util.*;

@Service
@RequiredArgsConstructor
public class UserClimbGroundServiceImp implements UserClimbGroundService{

    private final UserClimbGroundRepository userClimbGroundRepository;
    private final UserRepository userRepository;
    private final ClimbGroundRepository climbGroundRepository;

    // 년별 통계 조회
    @Override
    public ClimbRecordResponseDTO getUserClimbRecordYear(Long userId ,LocalDate date){
        List<UserClimbGround> userClimbGrounds = userClimbGroundRepository.findClimbRecordsByUserIdAndYear(userId,date.getYear());
        return makeClimbRecordResponseDTO(userClimbGrounds);
    };

    // 월별 통계 조회
    @Override
    public  ClimbRecordResponseDTO getUserClimbRecordMonth(Long userId ,LocalDate date){

        List<UserClimbGround> userClimbGrounds = userClimbGroundRepository.findClimbRecordsByUserIdAndMonth(userId,date.getYear(), date.getMonthValue());
        return makeClimbRecordResponseDTO(userClimbGrounds);
    }

    // 주별 통계 조회
    @Override
    public  ClimbRecordResponseDTO getUserClimbRecordWeek(Long userId ,LocalDate date){

        List<UserClimbGround> userClimbGrounds = userClimbGroundRepository.findClimbRecordsByUserIdAndWeek(userId,date.getYear(),date.get(ChronoField.ALIGNED_WEEK_OF_MONTH) );
        return makeClimbRecordResponseDTO(userClimbGrounds);
    }

    // 일별 통계 조회
    @Override
    public  ClimbRecordResponseDTO getUserClimbRecordDay(Long userId ,LocalDate date){

        List<UserClimbGround> userClimbGrounds = userClimbGroundRepository.findClimbRecordsByUserIdAndDay(userId,date.getYear(),date.getMonthValue(), date.getDayOfMonth());
        return makeClimbRecordResponseDTO(userClimbGrounds);
    }

    //ClimbRecordResponseDTO 만들어주는 메서드
    public ClimbRecordResponseDTO makeClimbRecordResponseDTO(List<UserClimbGround> userClimbGrounds ){
        Set<Long> uniqueClimbGrounds = new HashSet<>(); // 방문한 클라이밍장
        int totalSuccess =0;
        int totalTries =0;
        Map<HoldColorEnum, HoldStats> holdStatsMap = new HashMap<>(); // 색상별

        int totalVisited =0;

        for (UserClimbGround uc : userClimbGrounds) {

            uniqueClimbGrounds.add(uc.getClimbGround().getId());

            for (UserDate ud : uc.getUserDateList()){
                totalVisited++;
                for (ClimbingRecord r : ud.getClimbingRecordList()){
                    totalTries++;
                    if (r.isSuccess()) totalSuccess++;

                    //홀드 색상별로 정리
                    HoldColorEnum color = r.getHold().getColor();
                    holdStatsMap.putIfAbsent(color, new HoldStats(color,0,0));
                    HoldStats holdStats = holdStatsMap.get(color);
                    holdStats.setTryCount(holdStats.getTryCount() + 1);
                    if (r.isSuccess()){
                        holdStats.setSuccess(holdStats.getSuccess() + 1);
                    }
                }

            }
        }
        double successRate = ((double) totalSuccess / totalTries) * 100;
        successRate = Math.round(successRate * 100) / 100.0;
        List<Long> climbGroundList = new ArrayList<>(uniqueClimbGrounds);
        ClimbGroundStatus climbGroundStatus = new ClimbGroundStatus(
                uniqueClimbGrounds.size(),
                totalVisited,
                climbGroundList
        );
        List<HoldStats> holdStatsList = new ArrayList<>(holdStatsMap.values());

        return new ClimbRecordResponseDTO(climbGroundStatus,totalSuccess,successRate,totalTries,holdStatsList);
    }

    @Override
    public ResponseCode saveUnlockClimbGround(Long userId,
                                              Long climbGroundId) {
        Boolean is_unlock = userClimbGroundRepository.existsUserCLimbGroundByUserIdAndClimbGroundId(userId, climbGroundId);

        // 이미 해금되어 있으면
        if (is_unlock) {
            return ResponseCode.ALEADY_UNLUCKED;
        }

        User user = userRepository.findById(userId).orElse(null);
        ClimbGround climbGround = climbGroundRepository.findById(climbGroundId).orElse(null);
        if (user == null || climbGround == null) { // 유저나 클라이밍장이 없으면
            return ResponseCode.NOT_FOUND_CLIMB_GROUND_OR_USER;
        }

        UserClimbGround newUserClimbGround = new UserClimbGround();
        newUserClimbGround.setUser(user);
        newUserClimbGround.setClimbGround(climbGround);
        newUserClimbGround.setMedal(UserClimbGroundMedalEnum.NONE);
        userClimbGroundRepository.save(newUserClimbGround);
        return ResponseCode.POST_UNLUCK_CLIMB_GROUND;
    };

    @Override
    public ClimbGroundRecordResponseDTO getUserClimbGroundRecordYear(Long userId , Long climbGroundId,LocalDate date){
        List<UserClimbGround> userClimbGrounds = userClimbGroundRepository.findClimbRecordsByUserIdAndClimbGroundIdAndYear(
                userId,climbGroundId,date.getYear());

        return makeClimbGroundRecordResponseDTO(userClimbGrounds);
    }

    @Override
    public ClimbGroundRecordResponseDTO getUserClimbGroundRecordMonth(Long userId , Long climbGroundId,LocalDate date){
        List<UserClimbGround> userClimbGrounds = userClimbGroundRepository.findClimbRecordsByUserIdAndClimbGroundIdAndMonth(
                userId,climbGroundId,date.getYear(), date.getMonthValue());

        return makeClimbGroundRecordResponseDTO(userClimbGrounds);
    }

    @Override
    public ClimbGroundRecordResponseDTO getUserClimbGroundRecordWeek(Long userId , Long climbGroundId,LocalDate date){
        List<UserClimbGround> userClimbGrounds = userClimbGroundRepository.findClimbRecordsByUserIdAndClimbGroundIdAndWeek(
                userId,climbGroundId,date.getYear(),date.get(ChronoField.ALIGNED_WEEK_OF_MONTH));

        return makeClimbGroundRecordResponseDTO(userClimbGrounds);
    }

    @Override
    public ClimbGroundRecordResponseDTO getUserClimbGroundRecordDay(Long userId , Long climbGroundId, LocalDate date){
        List<UserClimbGround> userClimbGrounds = userClimbGroundRepository.findClimbRecordsByUserIdAndClimbGroundIdAndDay(
                userId,climbGroundId,date.getYear(), date.getMonthValue(), date.getDayOfMonth());

        return makeClimbGroundRecordResponseDTO(userClimbGrounds);
    }

    //ClimbGroundRecordResponseDTO 만들어주는 메서드
    public ClimbGroundRecordResponseDTO makeClimbGroundRecordResponseDTO(List<UserClimbGround> userClimbGrounds ){
        int totalSuccess =0;
        int totalTries =0;
        Map<HoldColorEnum, HoldStats> holdStatsMap = new HashMap<>(); // 색상별

        int totalVisited =0;
        String name= "";

        for (UserClimbGround uc : userClimbGrounds) {
            name = uc.getClimbGround().getName();
            for (UserDate ud : uc.getUserDateList()){
                totalVisited++;
                for (ClimbingRecord r : ud.getClimbingRecordList()){
                    totalTries++;
                    if (r.isSuccess()) totalSuccess++;

                    //홀드 색상별로 정리
                    HoldColorEnum color = r.getHold().getColor();
                    holdStatsMap.putIfAbsent(color, new HoldStats(color,0,0));
                    HoldStats holdStats = holdStatsMap.get(color);
                    holdStats.setTryCount(holdStats.getTryCount() + 1);
                    if (r.isSuccess()){
                        holdStats.setSuccess(holdStats.getSuccess() + 1);
                    }
                }

            }
        }
        double successRate = ((double) totalSuccess / totalTries) * 100;
        successRate = Math.round(successRate * 100) / 100.0;
        List<HoldStats> holdStatsList = new ArrayList<>(holdStatsMap.values());
        holdStatsList.sort(Comparator.comparing(HoldStats::getColor));

        return new ClimbGroundRecordResponseDTO(name,totalVisited,totalSuccess,successRate,totalTries,holdStatsList);
    }

    @Override
    public UnLockClimbGroundDetailResponseDTO getUnlockClimbGroundDetail(Long userId , Long climbGroundId){
        Optional<UserClimbGround> userClimbGround = userClimbGroundRepository.findByUserIdAndClimbGroundId(userId, climbGroundId);

        UnLockClimbGroundDetailResponseDTO detailResponseDTO = new UnLockClimbGroundDetailResponseDTO();
        if (userClimbGround.isPresent()){
            detailResponseDTO.setClimbGroundDetail(
                    userClimbGround.get().getClimbGround().getId(),
                    userClimbGround.get().getClimbGround().getName(),
                    userClimbGround.get().getClimbGround().getAddress(),
                    userClimbGround.get().getClimbGround().getImage()
            );
            // 총시도 횟수, 성공횟수 ,성공률
            int totalSuccess =0;
            int totalTries =0;

            for (UserDate ud : userClimbGround.get().getUserDateList()) {
                for (ClimbingRecord r : ud.getClimbingRecordList()){
                    totalTries++;
                    if (r.isSuccess()) totalSuccess++;

                }
            }
            double successRate = ((double) totalSuccess / totalTries) * 100;
            successRate = Math.round(successRate * 100) / 100.0;

            detailResponseDTO.setRecordDetail(
                    userClimbGround.get().getMedal(),
                    totalSuccess,
                    successRate,
                    totalTries
            );
            return detailResponseDTO;
        }
        throw new CustomException(ResponseCode.NOT_UNLOCK_CLIMB);
    }
}
