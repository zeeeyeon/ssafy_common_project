package com.project.backend.user.service.impl;

import com.project.backend.user.dto.request.LoginRequestDto;
import com.project.backend.user.dto.request.SignUpRequestDto;
import com.project.backend.user.dto.response.SignUpResponseDto;
import com.project.backend.user.entity.RoleRegister;
import com.project.backend.user.entity.User;
import com.project.backend.user.repository.jpa.RoleRegisterRepository;
import com.project.backend.user.repository.jpa.UserRepository;
import com.project.backend.user.service.UserService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;

@RequiredArgsConstructor
@Transactional
@Service
public class UserServiceImpl implements UserService {

  private final UserRepository userRepository;
  private final RoleRegisterRepository roleRegisterRepository;
  private final BCryptPasswordEncoder passwordEncoder;

  public User getUserByUserName(String userName){
    return userRepository.findByUsername(userName).orElseThrow();
  }

  @Override
  public ResponseEntity<?> signUp(SignUpRequestDto signUpRequestDto) {
    // 1) 해당 사용자의 입력 이메일이 이미 존재하는 계정인지 확인
    Optional<User> existedUser = userRepository.findByEmail(signUpRequestDto.getEmail());
    if(existedUser.isPresent()) return SignUpResponseDto.existedUserEmail();
    // 2) 해당 사용자의 입력 연락처가 이미 존재하는 계정인지 확인
    Optional<User> existedUserPhone = userRepository.findByPhone(signUpRequestDto.getPhone());
    if(existedUserPhone.isPresent()) return SignUpResponseDto.existedUserPhone();
    // 3) 해당 사용자의 입력 닉네임이 이미 존재하는 계정인지 확인
    Optional<User> existedUserNickname = userRepository.findByNickname(signUpRequestDto.getNickname());
    if(existedUserNickname.isPresent()) return SignUpResponseDto.existedUserNickname();

    // 1, 2, 3 해당 사항이 없다면 정상적으로 회원가입 진행
    userRepository.save(signUpRequestDto.toUserEntity(passwordEncoder));

    // role_register 테이블에도 해당 사항 등록
    User saveUser = userRepository.findByEmail(signUpRequestDto.getEmail()).orElseThrow(() -> new UsernameNotFoundException("해당 이메일을 가진 유저를 찾을 수 없습니다."));
    roleRegisterRepository.save(RoleRegister
            .builder()
            .userId(saveUser.getId())
            .roleId(2L)
            .createDate(LocalDateTime.now())
            .updateDate(LocalDateTime.now())
            .build());
    return SignUpResponseDto.success();
  }

  @Override
  public boolean checkEmailDuplication(String email) {
    return false;
  }

  @Override
  public boolean checkNicknameDuplication(String nickname) {
    return false;
  }
}
