package com.project.backend.user.service;

import com.project.backend.user.dto.UserTierRequestDto;
import com.project.backend.user.dto.request.SignUpRequestDto;
import com.project.backend.user.dto.request.UserInfoRequestDto;
import com.project.backend.user.dto.response.UserTierResponseDto;
import com.project.backend.user.entity.User;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public interface UserService {
  public User getUserByUserName(String userName);
  public void signUp(SignUpRequestDto signUpRequestDto);
  public Optional<User> checkEmailDuplication(String email);
  public Optional<User> checkNicknameDuplication(String nickname);
  public User userFindById(Long id);
  public User updateUserInfoById(Long id, UserInfoRequestDto requestDto);
  public UserTierResponseDto userTierFindById(Long id);
  public User insertUserTier(Long id, UserTierRequestDto requestDto);

}
