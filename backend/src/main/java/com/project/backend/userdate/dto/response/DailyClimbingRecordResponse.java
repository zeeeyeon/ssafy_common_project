package com.project.backend.userdate.dto.response;

import com.project.backend.hold.entity.HoldColorEnum;
import com.project.backend.hold.entity.HoldLevelEnum;
import lombok.Builder;
import lombok.Getter;

import java.util.Map;

@Getter
@Builder
public class DailyClimbingRecordResponse {
    // 클라이밍장 이름
    private String climbGroundName;
    // 해당 클라이밍장 방문 횟수 (회차)
    private int visitCount;
    // 완등 횟수
    private long successCount;
    // 완등률
    private double completionRate;
    // 해당 클라이밍장의 모든 색상-난이도
    private Map<HoldColorEnum, HoldLevelEnum> holdColorLevel;
    // 색상별 시도 횟수
    private Map<HoldColorEnum, Long> colorAttempts;
    // 색상별 성공 횟수
    private Map<HoldColorEnum, Long> colorSuccesses;

}

//{
//        "climbGroundName": "클라이밍장 이름",
//        "visitCount": 5,
//        "successCount": 12,
//        "completionRate": 65.5,
//        "holdColorLevel": {
//        "RED": "SEVEN",
//        "BLUE": "FIVE",
//        "YELLOW": "THREE"
//        },
//        "colorAttempts": {
//        "RED": 10,
//        "BLUE": 8,
//        "YELLOW": 5
//        },
//        "colorSuccesses": {
//        "RED": 7,
//        "BLUE": 4,
//        "YELLOW": 2
//        },
//}