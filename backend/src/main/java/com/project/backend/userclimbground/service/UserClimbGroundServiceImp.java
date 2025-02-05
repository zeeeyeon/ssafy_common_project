package com.project.backend.userclimbground.service;

import com.project.backend.climbground.entity.ClimbGround;
import com.project.backend.climbground.repository.ClimbGroundRepository;
import com.project.backend.common.response.ResponseCode;
import com.project.backend.user.entity.User;
import com.project.backend.user.repository.jpa.UserRepository;
import com.project.backend.userclimbground.dto.requestDTO.ClimbGroundRecordRequestDTO;
import com.project.backend.userclimbground.dto.requestDTO.UnlockClimbGroundRequsetDTO;
import com.project.backend.hold.entity.HoldColorEnum;
import com.project.backend.record.entity.ClimbingRecord;
import com.project.backend.userclimbground.dto.requestDTO.ClimbRecordRequestDTO;
import com.project.backend.userclimbground.dto.responseDTO.ClimbGroundRecordResponseDTO;
import com.project.backend.userclimbground.dto.responseDTO.ClimbGroundStatus;
import com.project.backend.userclimbground.dto.responseDTO.ClimbRecordResponseDTO;
import com.project.backend.userclimbground.dto.responseDTO.HoldStats;
import com.project.backend.userclimbground.entity.UserClimbGround;
import com.project.backend.userclimbground.entity.UserClimbGroundMedalEnum;
import com.project.backend.userclimbground.repository.UserClimbGroundRepository;
import com.project.backend.userdate.entity.UserDate;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;


import java.util.*;

@Service
@RequiredArgsConstructor
public class UserClimbGroundServiceImp implements UserClimbGroundService{

    private final UserClimbGroundRepository userClimbGroundRepository;
    private final UserRepository userRepository;
    private final ClimbGroundRepository climbGroundRepository;

    // 년별 통계 조회
    @Override
    public ClimbRecordResponseDTO getUserClimbRecordYear(ClimbRecordRequestDTO requestDTO){
        List<UserClimbGround> userClimbGrounds = userClimbGroundRepository.findClimbRecordsByUserIdAndYear(requestDTO.getUserId(),requestDTO.getYear());
        return makeClimbRecordResponseDTO(userClimbGrounds);
    };

    // 월별 통계 조회
    @Override
    public  ClimbRecordResponseDTO getUserClimbRecordMonth(ClimbRecordRequestDTO requestDTO){

        List<UserClimbGround> userClimbGrounds = userClimbGroundRepository.findClimbRecordsByUserIdAndMonth(requestDTO.getUserId(),requestDTO.getYear(), requestDTO.getMonth());
        return makeClimbRecordResponseDTO(userClimbGrounds);
    }

    // 주별 통계 조회
    @Override
    public  ClimbRecordResponseDTO getUserClimbRecordWeek(ClimbRecordRequestDTO requestDTO){

        List<UserClimbGround> userClimbGrounds = userClimbGroundRepository.findClimbRecordsByUserIdAndWeek(requestDTO.getUserId(),requestDTO.getYear(), requestDTO.getWeek());
        return makeClimbRecordResponseDTO(userClimbGrounds);
    }

    // 일별 통계 조회
    @Override
    public  ClimbRecordResponseDTO getUserClimbRecordDay(ClimbRecordRequestDTO requestDTO){

        List<UserClimbGround> userClimbGrounds = userClimbGroundRepository.findClimbRecordsByUserIdAndDay(requestDTO.getUserId(),requestDTO.getYear(), requestDTO.getMonth(), requestDTO.getDay());
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
    public ResponseCode saveUnlockClimbGround(UnlockClimbGroundRequsetDTO requestDTO) {
        Boolean is_unlock = userClimbGroundRepository.existsUserCLimbGroundByUserIdAndClimbGroundId(requestDTO.getUserId(),requestDTO.getClimbGroundId());

        // 이미 해금되어 있으면
        if (is_unlock) {
            return ResponseCode.ALEADY_UNLUCKED;
        }

        User user = userRepository.findById(requestDTO.getUserId()).orElse(null);
        ClimbGround climbGround = climbGroundRepository.findById(requestDTO.getClimbGroundId()).orElse(null);
        if (user == null || climbGround == null) { // 유저나 클라이밍장이 없으면
            return ResponseCode.NOT_FOUND_CLIMB_GROUND_OR_USER;
        }

        UserClimbGround newUserClimbGround = new UserClimbGround();
        newUserClimbGround.setUser(user);
        newUserClimbGround.setClimbGround(climbGround);
        newUserClimbGround.setMedal(UserClimbGroundMedalEnum.BRONZE);
        userClimbGroundRepository.save(newUserClimbGround);
        return ResponseCode.POST_UNLUCK_CLIMB_GROUND;
    };

    @Override
    public ClimbGroundRecordResponseDTO getUserClimbGroundRecordYear(ClimbGroundRecordRequestDTO requestDTO){
        List<UserClimbGround> userClimbGrounds = userClimbGroundRepository.findClimbRecordsByUserIdAndClimbGroundIdAndYear(
                requestDTO.getUserId(), requestDTO.getClimbGroundId(), requestDTO.getYear());

        return makeClimbGroundRecordResponseDTO(userClimbGrounds);
    }

    @Override
    public ClimbGroundRecordResponseDTO getUserClimbGroundRecordMonth(ClimbGroundRecordRequestDTO requestDTO){
        List<UserClimbGround> userClimbGrounds = userClimbGroundRepository.findClimbRecordsByUserIdAndClimbGroundIdAndMonth(
                requestDTO.getUserId(), requestDTO.getClimbGroundId(), requestDTO.getYear(), requestDTO.getMonth());

        return makeClimbGroundRecordResponseDTO(userClimbGrounds);
    }

    @Override
    public ClimbGroundRecordResponseDTO getUserClimbGroundRecordWeek(ClimbGroundRecordRequestDTO requestDTO){
        List<UserClimbGround> userClimbGrounds = userClimbGroundRepository.findClimbRecordsByUserIdAndClimbGroundIdAndWeek(
                requestDTO.getUserId(), requestDTO.getClimbGroundId(), requestDTO.getYear(), requestDTO.getWeek());

        return makeClimbGroundRecordResponseDTO(userClimbGrounds);
    }

    @Override
    public ClimbGroundRecordResponseDTO getUserClimbGroundRecordDay(ClimbGroundRecordRequestDTO requestDTO){
        List<UserClimbGround> userClimbGrounds = userClimbGroundRepository.findClimbRecordsByUserIdAndClimbGroundIdAndDay(
                requestDTO.getUserId(), requestDTO.getClimbGroundId(), requestDTO.getYear(), requestDTO.getMonth(), requestDTO.getDay());

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
}
