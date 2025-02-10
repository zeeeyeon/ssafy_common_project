package com.project.backend.userclimbground.dto.responseDTO;

import com.project.backend.userclimbground.entity.UserClimbGroundMedalEnum;
import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class UnLockClimbGroundDetailResponseDTO {

    private Long climbGroundId;
    private String name;
    private String address;
    private String imageUrl;
    private UserClimbGroundMedalEnum medal;
    private int success;
    private double success_rate;
    private int tryCount;

    public void setClimbGroundDetail(Long climbGroundId, String name, String address, String imageUrl) {
        this.climbGroundId = climbGroundId;
        this.name = name;
        this.address = address;
        this.imageUrl = imageUrl;
    }
    public void setRecordDetail(UserClimbGroundMedalEnum medal, int success, double successRate, int tryCount) {
        this.medal = medal;
        this.success = success;
        this.success_rate = successRate;
        this.tryCount = tryCount;
    }


}
