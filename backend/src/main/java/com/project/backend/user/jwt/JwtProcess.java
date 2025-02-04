package com.project.backend.user.jwt;


import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTVerificationException;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.exceptions.TokenExpiredException;
import com.auth0.jwt.interfaces.DecodedJWT;
import com.project.backend.oauth.entity.UserPrincipal;
import com.project.backend.user.entity.User;
import com.project.backend.user.entity.UserRoleEnum;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Base64;
import java.util.Date;

public class JwtProcess {
    private static final Logger log = LoggerFactory.getLogger(JwtProcess.class);

    // 토큰 생성
    public static String create(UserPrincipal loginUser, String secretKey) {
        try {
            log.debug("디버그 : JwtProcess create() 시작");

            byte[] decodedKey = Base64.getDecoder().decode(secretKey);
            Algorithm algorithm = Algorithm.HMAC512(decodedKey);

            String jwtToken = JWT.create()
                    .withSubject(loginUser.getUsername())
                    .withIssuedAt(new Date())
                    .withExpiresAt(new Date(System.currentTimeMillis() + JwtVO.EXPIRATION_TIME))
                    .withClaim("id", loginUser.getUser().getId())
                    .withClaim("email", loginUser.getUser().getEmail())
                    .withClaim("username", loginUser.getUser().getUsername())
                    .withClaim("role", loginUser.getUser().getRoleType().getCode())
                    .sign(algorithm);

            log.debug("디버그 : 생성된 토큰 = {}", jwtToken);
            return JwtVO.TOKEN_PREFIX + jwtToken;

        } catch (Exception e) {
            log.error("JWT 토큰 생성 실패: ", e);
            throw new RuntimeException("JWT 토큰 생성에 실패했습니다.");
        }
    }

    // 토큰 검증
    public static UserPrincipal verify(String token, String secretKey) {
        if (token == null || !token.startsWith(JwtVO.TOKEN_PREFIX)) {
            log.error("토큰이 null이거나 Bearer로 시작하지 않습니다. token: {}", token);
            throw new RuntimeException("유효하지 않은 토큰 형식입니다.");
        }

        try {
            String jwtToken = token.replace(JwtVO.TOKEN_PREFIX, "");
            log.debug("Bearer 제거된 토큰: {}", jwtToken);

            byte[] decodedKey = Base64.getDecoder().decode(secretKey);
            Algorithm algorithm = Algorithm.HMAC512(decodedKey);
            JWTVerifier verifier = JWT.require(algorithm).acceptLeeway(5).build();
            DecodedJWT decodedJWT = verifier.verify(jwtToken);

            Long id = decodedJWT.getClaim("id").asLong();
            String username = decodedJWT.getClaim("username").asString();
            String role = decodedJWT.getClaim("role").asString();
            String email = decodedJWT.getClaim("email").asString();

            User user = User.builder()
                    .id(id)
                    .email(email)
                    .username(username)
                    .roleType(UserRoleEnum.valueOf(role))
                    .build();

            return new UserPrincipal(user);

        } catch (TokenExpiredException e) {
            log.error("토큰이 만료됨. 만료시간: {}", e.getExpiredOn());
            throw new RuntimeException("만료된 토큰입니다.");

        } catch (JWTVerificationException e) {
            log.error("JWT 검증 실패. 원인: {}", e.getMessage());
            throw new RuntimeException("토큰 검증에 실패했습니다: " + e.getMessage());

        } catch (Exception e) {
            log.error("예상치 못한 에러 발생: ", e);
            throw new RuntimeException("토큰 처리 중 오류가 발생했습니다.");
        }
    }
}
