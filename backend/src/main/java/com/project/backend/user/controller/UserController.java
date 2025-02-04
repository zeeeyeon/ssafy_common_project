package com.project.backend.user.controller;

import com.project.backend.common.ApiResponse;
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

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserController {

  private final UserService userService;

  // 일반 사용자 회원가입
  @PostMapping("/signup")
  public ResponseEntity<?> signUp(@RequestBody @Valid SignUpRequestDto signUpRequestDto) {
    ResponseEntity<?> response = userService.signUp(signUpRequestDto);
    return response;
  }

  // 이메일 중복 체크
  @GetMapping("/email-check")
  public ApiResponse<Boolean> emailDuplicationCheck(@RequestParam(name = "email") String email) {
    boolean isDuplicated = userService.checkEmailDuplication(email);
    if(isDuplicated) {
      return ApiResponse.existedUserEmail();
    }
    else {
      return ApiResponse.noExistedUserEmail();
    }
  }

  // 닉네임 중복 체크
  @GetMapping("/nickname-check")
  public ApiResponse<Boolean> nicknameDuplicationCheck(@RequestParam(name = "nickname") String nickname) {
    boolean isDuplicated = userService.checkNicknameDuplication(nickname);
    if(isDuplicated) {
      return ApiResponse.existedUserNickname();
    }
    else {
      return ApiResponse.noExistedUserNickname();
    }
  }

}
