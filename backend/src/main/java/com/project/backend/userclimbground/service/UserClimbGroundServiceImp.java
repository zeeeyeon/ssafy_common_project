package com.project.backend.userclimbground.service;

import com.project.backend.hold.entity.HoldColorEnum;
import com.project.backend.record.entity.Record;
import com.project.backend.userclimbground.dto.requestDTO.ClimbRecordRequestDTO;
import com.project.backend.userclimbground.dto.responseDTO.ClimbGroundStatus;
import com.project.backend.userclimbground.dto.responseDTO.ClimbRecordResponseDTO;
import com.project.backend.userclimbground.dto.responseDTO.HoldStats;
import com.project.backend.userclimbground.entity.UserClimbGround;
import com.project.backend.userclimbground.repository.UserClimbGroundRepository;
import com.project.backend.userdate.entity.UserDate;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;


import java.util.*;

@Service
@RequiredArgsConstructor
public class UserClimbGroundServiceImp implements UserClimbGroundService{

    private final UserClimbGroundRepository userClimbGroundRepository;

    @Override
    public ClimbRecordResponseDTO getUserClimbRecordYear(ClimbRecordRequestDTO requestDTO){
        List<UserClimbGround> userClimbGrounds = userClimbGroundRepository.findClimbRecordsByUserIdAndYear(requestDTO.getUserId(),requestDTO.getYear());
        return makeClimbRecordResponseDTO(userClimbGrounds);
    };

    @Override
    public  ClimbRecordResponseDTO getUserClimbRecordMonth(ClimbRecordRequestDTO requestDTO){

        List<UserClimbGround> userClimbGrounds = userClimbGroundRepository.findClimbRecordsByUserIdAndMonth(requestDTO.getUserId(),requestDTO.getYear(), requestDTO.getMonth());
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
                for (Record r : ud.getRecordList()){
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
}
