package com.project.backend.user.controller;

import com.project.backend.common.ApiResponse;
import com.project.backend.common.ApiResponseHeader;
import com.project.backend.common.ResponseType;
import com.project.backend.oauth.entity.UserPrincipal;
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

  @GetMapping
  public ApiResponse getUser() {
    Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();

    if (principal instanceof UserPrincipal userPrincipal) {
      User user = userService.getUserByUserName(userPrincipal.getUsername());
      SignUpResDto signUpResDto = new SignUpResDto(user);
      return ApiResponse.success(signUpResDto);
    } else if (principal instanceof User user) {
      SignUpResDto signUpResDto = new SignUpResDto(user);
      return ApiResponse.success(signUpResDto);
    } else if (principal instanceof String username) { // principal이 String인 경우 처리
      User user = userService.getUserByUserName(username); // username 기반으로 User 조회
      SignUpResDto signUpResDto = new SignUpResDto(user);
      return ApiResponse.success(signUpResDto);
    }

    throw new RuntimeException("Unexpected principal type: " + principal.getClass());
  }



  @Value("${solapi.api.key}") // solapi 에서 발급받은 key
  private String apiKey;

  @Value("${solapi.api.secret}")
  private String secretKey; // solapi 메서 발급받은 secret key

  private DefaultMessageService messageService;

  @PostConstruct
  public void init() {
    // 반드시 계정 내 등록된 유효한 API 키, API Secret Key를 입력해주셔야 합니다!
    this.messageService = NurigoApp.INSTANCE.initialize(apiKey, secretKey, "https://api.solapi.com");
  }

  @PostMapping("/send-one")
  public SingleMessageSentResponse sendOne(@RequestBody SendOneRequestDto sendOneRequestDto) {
    Message message = new Message();
    message.setFrom("01086167589"); // 발신
    message.setTo(sendOneRequestDto.getPhone()); // 수신
    message.setText("SMS 인증 테스트 문자입니다."); // 텍스트

    SingleMessageSentResponse response = this.messageService.sendOne(new SingleMessageSendingRequest(message));
    return response;
  }

  // 일반 사용자 회원가입
  @PostMapping("/sign-up")
  public ResponseEntity<?> signUp(@RequestBody @Valid SignUpRequestDto signUpRequestDto) {
    ResponseEntity<?> response = userService.signUp(signUpRequestDto);
    return response;
  }

  // 일반 사용자 로그인
//  @PostMapping("/login")
//  public ResponseEntity<?> login(@RequestBody @Valid LoginRequestDto loginRequestDto) {
//    ResponseEntity<?> response = userService.login(loginRequestDto);
//    return response;
//  }

  // 이메일 중복 체크
  @GetMapping("/email-check")
  public ApiResponse<Boolean> emailDuplicationCheck(@RequestParam(name = "email") String email) {
    boolean isDuplicated = userService.checkEmailDuplication(email);
    if(isDuplicated) {
      return ApiResponse.existUserEmail();
    }
    else {
      return ApiResponse.success();
    }
  }



}
