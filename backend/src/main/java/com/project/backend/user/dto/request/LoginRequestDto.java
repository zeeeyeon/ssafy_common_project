package com.project.backend.user.dto.request;


import lombok.Data;

@Data
public class LoginRequestDto {

  private String username;
  private String password;
}
