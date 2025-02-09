package com.project.backend.user.dto.response;

import com.project.backend.user.entity.User;
import com.project.backend.user.entity.UserTierEnum;
import lombok.Data;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;

@Data
public class UserProfileResponseDto {
  private float height;
  private String armSpan;
  private int Dday;  // Changed to Long to allow null
  private UserTierEnum userTier;

  public UserProfileResponseDto(User user) {
    if (user == null) {
      throw new IllegalArgumentException("User cannot be null");
    }

    // Username/armSpan handling
    this.armSpan = user.getUsername() != null ? user.getUsername() : "";

    // Height handling
    this.height = user.getHeight();

    // UserTier handling
    this.userTier = user.getTier() != null ? user.getTier() : UserTierEnum.UNRANK;  // Assuming there's a DEFAULT enum value

    // D-day calculation with null check
    calculateDday(String.valueOf(user.getStartDate()));
  }

  private void calculateDday(String startDateStr) {
    if (startDateStr == null || startDateStr.trim().isEmpty()) {
      this.Dday = 0;
      return;
    }

    try {
      LocalDate startDate = LocalDate.parse(startDateStr);
      LocalDate currentDate = LocalDate.now();
      this.Dday = (int) ChronoUnit.DAYS.between(startDate, currentDate);
    } catch (DateTimeParseException e) {
      // Log the error if you have a logging system
      // logger.error("Failed to parse start date: " + startDateStr, e);
      this.Dday = 0;
    }
  }
}
