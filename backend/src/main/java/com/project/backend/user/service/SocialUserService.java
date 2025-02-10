package com.project.backend.user.service;

import com.project.backend.user.dto.KakaoUserInfoDto;
import com.project.backend.user.dto.request.AdditionalUserInfoDto;
import com.project.backend.user.entity.User;
import com.project.backend.user.repository.jpa.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class SocialUserService {

  private final UserRepository userRepository;
  private final BCryptPasswordEncoder passwordEncoder; // Bean 주입

  /**
   * 소셜 로그인 시 socialId를 통해 사용자가 존재하는지 확인하고,
   * 존재하지 않으면 신규 회원(GUEST)을 등록한다.
   */
  public User processSocialUser(KakaoUserInfoDto kakaoUserInfo, AdditionalUserInfoDto requestDto) {
    Optional<User> userOpt = userRepository.findBySocialId(kakaoUserInfo.getId());
    if (userOpt.isPresent()) {
      return userOpt.get();
    } else {
      String email = kakaoUserInfo.getKakaoAccount() != null ? kakaoUserInfo.getKakaoAccount().getEmail() : null;

      if(email == null) {
        throw new IllegalStateException("카카오 사용자 정보에 email이 존재하지 않습니다.");
      }

      String nickname = kakaoUserInfo.getKakaoAccount().getProfile().getNickname();

      if(nickname == null) {
        throw new IllegalStateException("카카오 사용자 정보에 nickname이 존재하지 않습니다.");
      }

      User newUser = User.builder()
              .socialId(kakaoUserInfo.getId())
              .email(email)
              .password(passwordEncoder.encode(requestDto.getPassword()))
              .nickname(requestDto.getNickname())
              .username(requestDto.getUsername())
              .phone(requestDto.getPhone())
              .build();
      return userRepository.save(newUser);
    }
  }
}
