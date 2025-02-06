package com.project.backend.user.dto.response;

import com.project.backend.userclimbground.entity.UserClimbGroundMedalEnum;
import lombok.Data;

@Data
public class UserMedalPerClimbGroundResponseDto {

  private UserClimbGroundMedalEnum medal;

  public UserMedalPerClimbGroundResponseDto(UserClimbGroundMedalEnum medal) {
    this.medal = medal;
  }
}
