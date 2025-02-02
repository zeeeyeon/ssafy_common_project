package com.project.backend.user.dto.request;


import jakarta.persistence.Entity;
import lombok.Data;

@Entity
@Data
public class LoginRequestDto {

  private String username;
  private String password;
}
