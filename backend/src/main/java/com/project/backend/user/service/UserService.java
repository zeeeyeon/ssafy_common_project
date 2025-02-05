package com.project.backend.user.service;

import com.project.backend.user.dto.request.SignUpRequestDto;
import com.project.backend.user.entity.User;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public interface UserService {
  public User getUserByUserName(String userName);

  public void signUp(SignUpRequestDto signUpRequestDto);

  public Optional<User> checkEmailDuplication(String email);

  public Optional<User> checkNicknameDuplication(String nickname);
  public Optional<User> userInfofindById(Long id);
}
