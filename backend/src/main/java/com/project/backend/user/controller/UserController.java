package com.project.backend.user.controller;

import com.project.backend.common.ApiResponse;
import com.project.backend.common.advice.exception.CustomException;
import com.project.backend.common.response.Response;
import com.project.backend.oauth.entity.UserPrincipal;
import com.project.backend.user.dto.request.LoginRequestDto;
import com.project.backend.user.dto.request.SendOneRequestDto;
import com.project.backend.user.dto.request.SignUpRequestDto;
import com.project.backend.user.dto.response.SignUpResDto;
import com.project.backend.user.entity.User;
import com.project.backend.user.service.UserService;
import jakarta.annotation.PostConstruct;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import net.nurigo.sdk.NurigoApp;
import net.nurigo.sdk.message.model.Message;
import net.nurigo.sdk.message.request.SingleMessageSendingRequest;
import net.nurigo.sdk.message.response.SingleMessageSentResponse;
import net.nurigo.sdk.message.service.DefaultMessageService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
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

}
