package com.project.backend.user.dto;

import com.project.backend.user.entity.UserTierEnum;
import lombok.Data;

@Data
public class UserTierRequestDto {
  private UserTierEnum userTier;


}
