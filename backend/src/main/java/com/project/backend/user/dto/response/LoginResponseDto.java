package com.project.backend.user.dto.response;

import com.project.backend.user.entity.User;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LoginResponseDto {
  private Long id;
  private String username;
  private String createdAt;

  public LoginResponseDto(User user) {
    this.id = user.getId();
    this.username = user.getUsername();
  }
}
