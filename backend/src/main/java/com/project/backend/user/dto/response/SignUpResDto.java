package com.project.backend.user.dto.response;

import com.project.backend.user.entity.User;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class SignUpResDto {
  private Long id;
  private String username;

  public SignUpResDto(User user) {
    this.id = user.getId();
    this.username = user.getUsername();
  }
}
