package com.project.backend.user.service;

import com.project.backend.user.dto.request.LoginRequestDto;
import com.project.backend.user.dto.request.SignUpRequestDto;
import com.project.backend.user.entity.User;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

@Service
public interface UserService {
  public User getUserByUserName(String userName);

  public ResponseEntity<?> signUp(SignUpRequestDto signUpRequestDto);

  public boolean checkEmailDuplication(String email);

  public boolean checkNicknameDuplication(String nickname);

  User getEmail(String email);

}
