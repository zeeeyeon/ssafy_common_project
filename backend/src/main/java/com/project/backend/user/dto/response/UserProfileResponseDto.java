package com.project.backend.user.dto.response;

import com.project.backend.user.entity.User;
import com.project.backend.user.entity.UserTierEnum;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;

@Data
public class UserProfileResponseDto {
  private String nickname;
  private float height;
  private float armSpan;
  private String profileImageUrl;
  private int Dday;  // Changed to Long to allow null
  private UserTierEnum userTier;

  public UserProfileResponseDto(User user) {
    if (user == null) {
      throw new IllegalArgumentException("User cannot be null");
    }
    this.nickname = user.getNickname() != null ? user.getNickname() : "";
    // armSpan handling
    this.armSpan = user.getReach() != null ? user.getReach() : 0;

    // Height handling
    this.height = user.getHeight() != null ? user.getHeight() : 0;

    // UserTier handling
    this.userTier = user.getTier() != null ? user.getTier() : UserTierEnum.UNRANK;  // Assuming there's a DEFAULT enum value

    this.profileImageUrl = user.getProfileImageUrl();
    // D-day calculation with null check
    this.Dday = calculateDday(String.valueOf(user.getStartDate()));
  }

  private int calculateDday(String startDateStr) {
    LocalDateTime startDate = LocalDateTime.parse(startDateStr);
    LocalDateTime currentDate = LocalDateTime.now();
    return (int) ChronoUnit.DAYS.between(startDate, currentDate);
  }
}
