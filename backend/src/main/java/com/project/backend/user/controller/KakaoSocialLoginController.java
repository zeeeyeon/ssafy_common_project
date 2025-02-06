package com.project.backend.user.controller;

import com.project.backend.common.response.Response;
import com.project.backend.common.response.ResponseCode;
import com.project.backend.user.auth.CustomUserDetails;
import com.project.backend.user.dto.KakaoTokenResponseDto;
import com.project.backend.user.dto.KakaoUserInfoDto;
import com.project.backend.user.dto.response.KakaoLoginResponseDto;
import com.project.backend.user.entity.User;
import com.project.backend.user.jwt.JwtProcess;
import com.project.backend.user.jwt.JwtVO;
import com.project.backend.user.service.KakaoOauthService;
import com.project.backend.user.service.RefreshTokenService;
import com.project.backend.user.service.SocialUserService;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;

import static com.project.backend.common.response.ResponseCode.SUCCESS_LOGIN;

@RestController
@RequestMapping("/api/user/social/kakao")
@RequiredArgsConstructor
public class KakaoSocialLoginController {

  private final KakaoOauthService kakaoOauthService;
  private final SocialUserService socialUserService;
  private final RefreshTokenService refreshTokenService;
  private final Logger log = LoggerFactory.getLogger(getClass());

  // 1. 카카오 로그인 페이지로 리다이렉트
  @GetMapping("/login")
  public void redirectToKakao(HttpServletResponse response) throws IOException {
    String kakaoAuthUrl = kakaoOauthService.getAuthorizationUrl();
    response.sendRedirect(kakaoAuthUrl);
  }

  // 2. 카카오로부터 인가 코드 수신 및 처리
  @GetMapping("/callback")
  public ResponseEntity<?> kakaoCallback(@RequestParam("code") String code, HttpServletResponse response) {
    // 카카오 토큰 요청
    KakaoTokenResponseDto tokenResponse = kakaoOauthService.getAccessToken(code);

    log.info(tokenResponse.getAccessToken());
    log.info(tokenResponse.getRefreshToken());
    log.info(tokenResponse.getExpiresIn().toString());

    // 카카오 사용자 정보 요청
    KakaoUserInfoDto kakaoUserInfo = kakaoOauthService.getUserInfo(tokenResponse.getAccessToken());

    // 소셜 로그인 회원 처리 (신규 가입 또는 기존 회원 조회)
    User user = socialUserService.processSocialUser(kakaoUserInfo);

    // User 객체를 CustomUserDetails로 감싸기
    CustomUserDetails customUserDetails = new CustomUserDetails(user);

    // JWT 토큰 생성 (Access, Refresh)
    String jwtAccessToken = JwtProcess.create(customUserDetails);
    String jwtRefreshToken = JwtProcess.createRefreshToken(customUserDetails);

    // Refresh Token 저장 (예: Redis 또는 DB)
    refreshTokenService.saveRefreshToken(user.getId(), jwtRefreshToken);

    return new ResponseEntity<>((Response.create(SUCCESS_LOGIN, new KakaoLoginResponseDto(jwtAccessToken, jwtRefreshToken))), SUCCESS_LOGIN.getHttpStatus() );
  }
}
