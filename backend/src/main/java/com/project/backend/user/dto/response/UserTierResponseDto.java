package com.project.backend.user.dto.response;

import com.project.backend.user.entity.User;
import com.project.backend.user.entity.UserTierEnum;
import lombok.Data;

@Data
public class UserTierResponseDto {
  private UserTierEnum userTier;

  public UserTierResponseDto(User user) {
    this.userTier = user.getTier();
  }
}
