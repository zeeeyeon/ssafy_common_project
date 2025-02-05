package com.project.backend.user.service.impl;

import com.project.backend.common.advice.exception.CustomException;
import com.project.backend.common.response.ResponseCode;
import com.project.backend.user.dto.request.SignUpRequestDto;
import com.project.backend.user.entity.User;
import com.project.backend.user.repository.jpa.UserRepository;
import com.project.backend.user.service.UserService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@RequiredArgsConstructor
@Transactional
@Service
public class UserServiceImpl implements UserService {

  private final UserRepository userRepository;
  private final BCryptPasswordEncoder passwordEncoder;

  public User getUserByUserName(String userName){
    return userRepository.findByUsername(userName).orElseThrow();
  }

  @Override
  public void signUp(SignUpRequestDto signUpRequestDto) {
    // 1) 해당 사용자의 입력 이메일이 이미 존재하는 계정인지 확인
    Optional<User> existedUser = userRepository.findByEmail(signUpRequestDto.getEmail());
    if(existedUser.isPresent()) {
      throw new CustomException(ResponseCode.EXISTED_USER_EMAIL);
    }
    // 2) 해당 사용자의 입력 연락처가 이미 존재하는 계정인지 확인
    Optional<User> existedUserPhone = userRepository.findByPhone(signUpRequestDto.getPhone());
    if(existedUserPhone.isPresent()) {
      throw new CustomException(ResponseCode.EXISTED_USER_PHONE);
    }
    // 3) 해당 사용자의 입력 닉네임이 이미 존재하는 계정인지 확인
    Optional<User> existedUserNickname = userRepository.findByNickname(signUpRequestDto.getNickname());
    if(existedUserNickname.isPresent()) {
      throw new CustomException(ResponseCode.EXISTED_USER_NICKNAME);
    }
    // 4) 비밀번호와 비밀번호 확인 정보가 일치하지 않는지 확인
    if (!signUpRequestDto.getPassword().equals(signUpRequestDto.getPasswordConfirm())) {
      throw new CustomException(ResponseCode.MISMATCH_PASSWORD);
    }

    // 1, 2, 3, 4 해당 사항이 없다면 정상적으로 회원가입 진행
    userRepository.save(signUpRequestDto.toUserEntity(passwordEncoder));

  }

  @Override
  public Optional<User> checkEmailDuplication(String email) {
    return userRepository.findByEmail(email);
  }

  @Override
  public Optional<User> checkNicknameDuplication(String nickname) {
    return userRepository.findByNickname(nickname);
  }

  public Optional<User> userInfofindById(Long id) {
    return userRepository.findById(id);
  }
}
