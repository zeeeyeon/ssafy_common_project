package com.project.backend.user.service.impl;

import com.project.backend.user.dto.request.LoginRequestDto;
import com.project.backend.user.dto.request.SignUpRequestDto;
import com.project.backend.user.dto.response.SignUpResponseDto;
import com.project.backend.user.entity.RoleRegister;
import com.project.backend.user.entity.User;
import com.project.backend.user.ex.CustomApiException;
import com.project.backend.user.ex.ErrorCode;
import com.project.backend.user.repository.jpa.RoleRegisterRepository;
import com.project.backend.user.repository.jpa.UserRepository;
import com.project.backend.user.service.UserService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@RequiredArgsConstructor
@Transactional
@Service
public class UserServiceImpl implements UserService {

  private final UserRepository userRepository;
  private final RoleRegisterRepository roleRegisterRepository;
  private final BCryptPasswordEncoder passwordEncoder;

  public User getUserByUserName(String userName){
    return userRepository.findByUsername(userName).orElseThrow(() -> new CustomApiException(ErrorCode.USER_NOT_EXIST));
  }

  @Override
  public ResponseEntity<?> signUp(SignUpRequestDto signUpRequestDto) {
    // 1) 해당 사용자의 입력 이메일이 이미 존재하는 계정인지 확인
    User existedUser = userRepository.findByEmail(signUpRequestDto.getEmail());
    if(existedUser != null) return SignUpResponseDto.existedUserEmail();
    // 2) 해당 사용자의 입력 연락처가 이미 존재하는 계정인지 확인
    User existedUserPhone = userRepository.findByPhone(signUpRequestDto.getPhone());
    if(existedUserPhone != null) return SignUpResponseDto.existedUserPhone();
    // 3) 해당 사용자의 입력 닉네임이 이미 존재하는 계정인지 확인
    User existedUserNickname = userRepository.findByNickname(signUpRequestDto.getNickname());
    if(existedUserNickname != null) return SignUpResponseDto.existedUserNickname();

    // 1, 2, 3 해당 사항이 없다면 정상적으로 회원가입 진행
    userRepository.save(signUpRequestDto.toUserEntity(passwordEncoder));

    // role_register 테이블에도 해당 사항 등록
    User saveUser = userRepository.findByEmail(signUpRequestDto.getEmail());
    roleRegisterRepository.save(RoleRegister
            .builder()
            .userId(saveUser.getId())
            .roleId(2L)
            .createDate(LocalDateTime.now())
            .updateDate(LocalDateTime.now())
            .build());
    return SignUpResponseDto.success();
  }

  public boolean checkEmailDuplication(String email) {
    return userRepository.existsByEmail(email);
  }

  public boolean checkNicknameDuplication(String nickname) {
    return userRepository.existsByNickname(nickname);
  }

  @Override
  public ResponseEntity<?> login(LoginRequestDto loginRequestDto) {
    return null;
  }

//  ResponseEntity<?> login(LoginRequestDto loginRequestDto) {
//    return userRepository.
//  }

}
