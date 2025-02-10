package com.project.backend.user.controller;

import com.project.backend.common.advice.exception.CustomException;
import com.project.backend.common.response.Response;
import com.project.backend.common.response.ResponseCode;
import com.project.backend.user.auth.CustomUserDetails;
import com.project.backend.user.dto.KakaoTokenResponseDto;
import com.project.backend.user.dto.KakaoUserInfoDto;
import com.project.backend.user.dto.request.AdditionalUserInfoDto;
import com.project.backend.user.entity.User;
import com.project.backend.user.jwt.JwtProcess;
import com.project.backend.user.service.KakaoOauthService;
import com.project.backend.user.service.RefreshTokenService;
import com.project.backend.user.service.SocialUserService;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;

import static com.project.backend.common.response.ResponseCode.*;

@RestController
@RequestMapping("/api/user/social/kakao")
@RequiredArgsConstructor
public class KakaoSocialLoginController {

  private final KakaoOauthService kakaoOauthService;
  private final SocialUserService socialUserService;
  private final Logger log = LoggerFactory.getLogger(getClass());

  // 1. 카카오 로그인 페이지로 리다이렉트
  @GetMapping("/login")
  public void redirectToKakao(HttpServletResponse response) throws IOException {
    String kakaoAuthUrl = kakaoOauthService.getAuthorizationUrl();
    response.sendRedirect(kakaoAuthUrl);
  }

  @GetMapping("/callback")
  public ResponseEntity<?> kakaoCallback1(@RequestParam("code") String code) {
    // 카카오 토큰 요청 및 사용자 정보 조회
    KakaoTokenResponseDto tokenResponse = kakaoOauthService.getAccessToken(code);

    // 추가 정보 입력 페이지로 리다이렉션하거나 클라이언트에 해당 정보를 전달
    return new ResponseEntity<>(Response.create(SUCCESS_SOCIAL_LOGIN, tokenResponse), SUCCESS_SOCIAL_LOGIN.getHttpStatus());
  }

  @PostMapping("/complete-signup")
  public ResponseEntity<?> kakaoCallback2(@RequestBody AdditionalUserInfoDto requestDto, HttpServletResponse response) {

    KakaoUserInfoDto kakaoUserInfo = kakaoOauthService.getUserInfo(requestDto.getAccessToken());

    // 소셜 로그인 회원 처리 (신규 가입 또는 기존 회원 조회)
    User user = socialUserService.processSocialUser(kakaoUserInfo, requestDto);

    // User 객체를 CustomUserDetails로 감싸기
    CustomUserDetails customUserDetails = new CustomUserDetails(user);

    // JWT 토큰 생성 (Access, Refresh)
    String jwtAccessToken = JwtProcess.create(customUserDetails);

    response.addHeader("Authorization", jwtAccessToken);

    return new ResponseEntity<>((Response.create(SUCCESS_LOGIN, null)), SUCCESS_LOGIN.getHttpStatus());
  }


}
