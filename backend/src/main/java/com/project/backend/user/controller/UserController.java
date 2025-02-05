package com.project.backend.user.controller;

import com.project.backend.common.advice.exception.CustomException;
import com.project.backend.common.response.Response;
import com.project.backend.common.response.ResponseCode;
import com.project.backend.user.auth.CustomUserDetails;
import com.project.backend.user.dto.request.SignUpRequestDto;
import com.project.backend.user.dto.request.UserInfoRequestDto;
import com.project.backend.user.dto.response.UserInfoResponseDto;
import com.project.backend.user.entity.User;
import com.project.backend.user.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

import static com.project.backend.common.response.ResponseCode.*;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserController {

  private final UserService userService;

  // 일반 사용자 회원가입
  @PostMapping("/signup")
  public ResponseEntity<?> signUp(@RequestBody @Valid SignUpRequestDto signUpRequestDto) {
    userService.signUp(signUpRequestDto);
    return new ResponseEntity<>(Response.create(SUCCESS_SIGNUP, null), SUCCESS_SIGNUP.getHttpStatus());
  }

  // 이메일 중복 체크
  @GetMapping("/email-check")
  public ResponseEntity<?> emailDuplicationCheck(@RequestParam(name = "email") String email) {
    Optional<User> user = userService.checkEmailDuplication(email);
    if(user.isPresent()) {
      throw new CustomException(EXISTED_USER_EMAIL);
    }
    return new ResponseEntity<>(Response.create(NO_EXISTED_USER_EMAIL, null), NO_EXISTED_USER_EMAIL.getHttpStatus());
  }

  // 닉네임 중복 체크
  @GetMapping("/nickname-check")
  public ResponseEntity<?> nicknameDuplicationCheck(@RequestParam(name = "nickname") String nickname) {
    Optional<User> user = userService.checkNicknameDuplication(nickname);
    if(user.isPresent()) {
      throw new CustomException(EXISTED_USER_NICKNAME);
    }
    return new ResponseEntity<>(Response.create(NO_EXISTED_USER_NICKNAME, null), NO_EXISTED_USER_NICKNAME.getHttpStatus());
  }

  // 사용자 정보 조회 ( 이름, 클라이밍 시작일, 키, 팔길이)
  @GetMapping("/info")
  public ResponseEntity<?> findUserInfo(@AuthenticationPrincipal CustomUserDetails userDetails) {
    Long userId = userDetails.getUser().getId();
    User user = userService.userInfofindById(userId);
    UserInfoResponseDto responseDto = new UserInfoResponseDto(user);
    return new ResponseEntity<>(Response.create(ResponseCode.GET_USER_INFO, responseDto), GET_USER_INFO.getHttpStatus());
  }

  @PutMapping("/info")
  public ResponseEntity<?> updateUserInfo(@AuthenticationPrincipal CustomUserDetails userDetails, @RequestBody UserInfoRequestDto requestDto) {
    Long userId = userDetails.getUser().getId();
    User findUser = userService.updateUserInfoById(userId, requestDto);
    UserInfoResponseDto responseDto = new UserInfoResponseDto(findUser);
    return new ResponseEntity<>(Response.create(ResponseCode.GET_USER_INFO, responseDto), GET_USER_INFO.getHttpStatus());
  }

}
