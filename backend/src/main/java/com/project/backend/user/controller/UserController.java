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
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserController {

  private final UserService userService;

  @GetMapping
  public ApiResponse getUser() {
    Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
    Object principal = authentication.getPrincipal();

    String email;

    if (principal instanceof OAuth2User) {
      // OAuth2 인증 사용 시
      OAuth2User oauth2User = (OAuth2User) principal;
      email = oauth2User.getAttribute("email");
    } else if (principal instanceof UserDetails) {
      // JWT 또는 일반 Spring Security 인증 사용 시
      UserDetails userDetails = (UserDetails) principal;
      email = userDetails.getUsername(); // UserDetails는 username 필드를 사용 (email로 저장된 경우)
    } else {
      throw new RuntimeException("Unknown authentication type: " + principal.getClass().getName());
    }

    User user = userService.getEmail(email);
    return ApiResponse.success("user", user);
  }



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

  @GetMapping("/profile")
  public String profile(@AuthenticationPrincipal UserPrincipal userPrincipal) {
    String email = userPrincipal.getEmail();
    String name = userPrincipal.getUsername();
    return "User Email: " + email + ", Name: " + name;
  }
}
