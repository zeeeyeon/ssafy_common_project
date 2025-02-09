package com.project.backend.user.jwt;


import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTDecodeException;
import com.auth0.jwt.exceptions.JWTVerificationException;
import com.auth0.jwt.exceptions.SignatureVerificationException;
import com.auth0.jwt.exceptions.TokenExpiredException;
import com.auth0.jwt.interfaces.DecodedJWT;
import com.project.backend.common.advice.exception.CustomException;
import com.project.backend.common.response.ResponseCode;
import com.project.backend.user.auth.CustomUserDetails;
import com.project.backend.user.entity.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Date;

import static com.project.backend.common.response.ResponseCode.MISSING_MANDATORY_CLAIMS;

public class JwtProcess {
    private static final Logger log = LoggerFactory.getLogger(JwtProcess.class);

    // 토큰 생성
    public static String create(CustomUserDetails loginUser) {
        try {
            log.debug("디버그 : JwtProcess create() 시작");

            String jwtToken = JWT.create()
                    .withSubject(loginUser.getUsername())
                    .withIssuedAt(new Date()) // 토큰 발급 시간
                    .withExpiresAt(new Date(System.currentTimeMillis() + JwtVO.EXPIRATION_TIME))
                    .withClaim("id", loginUser.getUser().getId())
                    .withClaim("username", loginUser.getUser().getUsername())
                    .sign(Algorithm.HMAC512(JwtVO.SECRET));

            log.debug("디버그 : 생성된 토큰 = {}", jwtToken);
            return JwtVO.TOKEN_PREFIX + jwtToken;

        } catch (Exception e) {
            log.error("JWT 토큰 생성 실패: ", e);
            throw new RuntimeException("JWT Access Token 생성 실패");
        }
    }

    // Refresh Token 생성
    public static String createRefreshToken(CustomUserDetails user) {
        try {
            String refreshToken = JWT.create()
                    .withSubject(user.getUser().getId() + "")
                    .withIssuedAt(new Date())
                    .withExpiresAt(new Date(System.currentTimeMillis() + JwtVO.REFRESH_EXPIRATION_TIME))
                    .sign(Algorithm.HMAC512(JwtVO.SECRET));
            return JwtVO.TOKEN_PREFIX + refreshToken;
        } catch (Exception e) {
            log.error("JWT Refresh Token 생성 실패", e);
            throw new RuntimeException("JWT Refresh Token 생성 실패");
        }
    }

    // 토큰 검증
    public static CustomUserDetails verify(String token) {
        if (token == null || !token.startsWith(JwtVO.TOKEN_PREFIX)) {
            log.error("토큰이 null이거나 Bearer로 시작하지 않습니다. token: {}", token);
            throw new CustomException(ResponseCode.INVALID_TOKEN_FORMAT);
        }

        try {
            // 입력된 토큰 로깅
            log.debug("검증할 원본 토큰: {}", token);

            // Bearer 제거된 토큰 로깅
            String jwtToken = token.replace(JwtVO.TOKEN_PREFIX, "");
            log.debug("Bearer 제거된 토큰: {}", jwtToken);

            // 사용되는 시크릿 키 로깅 (개발환경에서만 사용)
            log.debug("사용되는 시크릿 키 길이: {}", JwtVO.SECRET.length());

            // JWT 검증 시도
            log.debug("JWT 검증 시작...");
            DecodedJWT decodedJWT = JWT.require(Algorithm.HMAC512(JwtVO.SECRET))
                    .acceptLeeway(5) // 5초의 시간 오차 허용
                    .build()
                    .verify(jwtToken);

            // 검증 성공 시 토큰 내용 로깅
            log.debug("JWT 검증 성공. 발행일: {}, 만료일: {}",
                    decodedJWT.getIssuedAt(),
                    decodedJWT.getExpiresAt());

            Long id = decodedJWT.getClaim("id").asLong();
            String username = decodedJWT.getClaim("username").asString();
            String role = decodedJWT.getClaim("role").asString();

            log.debug("토큰에서 추출된 정보 - id: {}, username: {}, role: {}",
                    id, username, role);

            if (id == null || username == null || role == null) {
                throw new CustomException(MISSING_MANDATORY_CLAIMS);
            }

            User user = User.builder()
                    .id(id)
                    .username(username)
                    .build();

            return new CustomUserDetails(user);

        } catch (TokenExpiredException e) {
            log.error("토큰이 만료됨. 만료시간: {}", e.getExpiredOn());
            throw new RuntimeException("만료된 토큰입니다.");

        } catch (SignatureVerificationException e) {
            log.error("JWT 서명 검증 실패. 원인: {}", e.getMessage());
            throw new RuntimeException("토큰 서명이 유효하지 않습니다.");

        } catch (JWTDecodeException e) {
            log.error("JWT 디코딩 실패. 유효하지 않은 토큰 형식. 원인: {}", e.getMessage());
            throw new RuntimeException("유효하지 않은 토큰 형식입니다.");

        } catch (JWTVerificationException e) {
            log.error("JWT 검증 실패. 원인: {}", e.getMessage());
            throw new RuntimeException("토큰 검증에 실패했습니다: " + e.getMessage());

        } catch (Exception e) {
            log.error("예상치 못한 에러 발생: ", e);
            throw new RuntimeException("토큰 처리 중 오류가 발생했습니다.");
        }
    }
}
