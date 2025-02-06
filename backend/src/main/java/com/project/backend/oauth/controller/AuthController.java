package com.project.backend.oauth.controller;

import com.project.backend.common.ApiResponse;
import com.project.backend.oauth.dto.AuthReqDto;
import com.project.backend.oauth.entity.UserPrincipal;
import com.project.backend.oauth.token.AuthToken;
import com.project.backend.oauth.token.AuthTokenProvider;
import com.project.backend.config.properties.AppProperties;
import com.project.backend.oauth.utils.CookieUtil;
import com.project.backend.oauth.utils.HeaderUtil;
import com.project.backend.user.entity.UserRefreshToken;
import com.project.backend.user.entity.UserRoleEnum;
import io.jsonwebtoken.Claims;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.Date;

//@RestController
//@RequestMapping("/api/v1/auth")
//@RequiredArgsConstructor
//public class AuthController {
//
//  private final AppProperties appProperties;
//  private final AuthTokenProvider tokenProvider;
//  private final AuthenticationManager authenticationManager;
//
//  private static final long THREE_DAYS_MSEC = 259200000;
//  private static final String ACCESS_TOKEN = "access_token";
//  private static final String REFRESH_TOKEN = "refresh_token";
//
//  @PostMapping("/login")
//  public ApiResponse login(
//          HttpServletRequest request,
//          HttpServletResponse response,
//          @RequestBody AuthReqDto authReqModel
//  ) {
//    Authentication authentication = authenticationManager.authenticate(
//            new UsernamePasswordAuthenticationToken(
//                    authReqModel.getUserName(),
//                    authReqModel.getPassword()
//            )
//    );
//
//    String userName = authReqModel.getUserName();
//    SecurityContextHolder.getContext().setAuthentication(authentication);
//
//    Date now = new Date();
//    long accessTokenExpiry = appProperties.getAuth().getTokenExpiry();
//    AuthToken accessToken = tokenProvider.createAuthToken(
//            userName,
//            ((UserPrincipal) authentication.getPrincipal()).getRoleType().getCode(),
//            new Date(now.getTime() + accessTokenExpiry)
//    );
//
//    long refreshTokenExpiry = appProperties.getAuth().getRefreshTokenExpiry();
//    AuthToken refreshToken = tokenProvider.createAuthToken(
//            appProperties.getAuth().getTokenSecret(),
//            new Date(now.getTime() + refreshTokenExpiry)
//    );
//
//    // Redis에 저장할 UserRefreshToken 객체 생성
//    // Redis 토큰 저장 단순화
//    UserRefreshToken userRefreshToken = new UserRefreshToken();
//    userRefreshToken.setUserName(userName);
//    userRefreshToken.setRefreshToken(refreshToken.getToken());
//    userRefreshToken.setExpirationDate(new Date(now.getTime() + refreshTokenExpiry));
//
//    userRefreshTokenRepository.save(userRefreshToken);
//
//    int cookieAccessTokenMaxAge = (int) accessTokenExpiry / 60;
//    CookieUtil.deleteCookie(request, response, ACCESS_TOKEN);
//    CookieUtil.addCookie(response, ACCESS_TOKEN, accessToken.getToken(), cookieAccessTokenMaxAge);
//
//    return ApiResponse.success();
//  }
//
//  @GetMapping("/refresh")
//  public ApiResponse<String> refreshToken(HttpServletRequest request, HttpServletResponse response) {
//    // Access token 검증
//    String accessToken = HeaderUtil.getAccessToken(request);
//    AuthToken authToken = tokenProvider.convertAuthToken(accessToken);
//
//    if (!authToken.validate()) {
//      return ApiResponse.invalidAccessToken();
//    }
//
//    // Expired access token 확인
//    Claims claims = authToken.getExpiredTokenClaims();
//    if (claims == null) {
//      return ApiResponse.notExpiredTokenYet();
//    }
//
//    String userName = claims.getSubject();
//    UserRoleEnum roleType = UserRoleEnum.of(claims.get("role", String.class));
//
//    // Refresh token 추출
//    String refreshToken = CookieUtil.getCookie(request, REFRESH_TOKEN)
//            .map(Cookie::getValue)
//            .orElse(null);
//    AuthToken authRefreshToken = tokenProvider.convertAuthToken(refreshToken);
//
//    // Refresh token 유효성 검사
//    if (!authRefreshToken.validate()) {
//      return ApiResponse.invalidRefreshToken();
//    }
//
//    // Redis에서 refresh token 확인
//    UserRefreshToken userRefreshToken = userRefreshTokenRepository.findByUserNameAndRefreshToken(userName, refreshToken);
//    if (userRefreshToken == null) {
//      return ApiResponse.invalidRefreshToken();
//    }
//
//    Date now = new Date();
//    AuthToken newAccessToken = createNewAccessToken(userName, roleType, now);
//
//    // Refresh token 갱신 로직
//    handleRefreshTokenRenewal(request, response, authRefreshToken, userName, userRefreshToken, now);
//
//    return ApiResponse.success("token", newAccessToken.getToken());
//  }
//
//  private AuthToken createNewAccessToken(String userId, UserRoleEnum roleType, Date now) {
//    return tokenProvider.createAuthToken(
//            userId,
//            roleType.getCode(),
//            new Date(now.getTime() + appProperties.getAuth().getTokenExpiry())
//    );
//  }
//
//  private void handleRefreshTokenRenewal(HttpServletRequest request,
//                                         HttpServletResponse response,
//                                         AuthToken authRefreshToken,
//                                         String userName,
//                                         UserRefreshToken userRefreshToken,
//                                         Date now) {
//    long validTime = authRefreshToken.getTokenClaims().getExpiration().getTime() - now.getTime();
//
//    // Refresh 토큰 기간이 3일 이하로 남은 경우, 토큰 갱신
//    if (validTime <= THREE_DAYS_MSEC) {
//      long refreshTokenExpiry = appProperties.getAuth().getRefreshTokenExpiry();
//      AuthToken newRefreshToken = tokenProvider.createAuthToken(
//              appProperties.getAuth().getTokenSecret(),
//              new Date(now.getTime() + refreshTokenExpiry)
//      );
//
//      // Redis 토큰 저장 단순화
//      UserRefreshToken newUserRefreshToken = new UserRefreshToken();
//      userRefreshToken.setUserName(userName);
//      userRefreshToken.setRefreshToken(newRefreshToken.getToken());
//      userRefreshToken.setExpirationDate(new Date(now.getTime() + refreshTokenExpiry));
//
//      userRefreshTokenRepository.save(newUserRefreshToken);
//
//      // 쿠키 업데이트
//      int cookieMaxAge = (int) refreshTokenExpiry / 60;
//      CookieUtil.deleteCookie(request, response, REFRESH_TOKEN);
//      CookieUtil.addCookie(response, REFRESH_TOKEN, newRefreshToken.getToken(), cookieMaxAge);
//    }
//  }
//}
