package com.project.backend.user.jwt;


import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.interfaces.DecodedJWT;
import com.project.backend.user.auth.LoginUser;
import com.project.backend.user.entity.User;
import com.project.backend.user.entity.UserRoleEnum;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.auth0.jwt.JWT;
import java.util.Date;

public class JwtProcess {

    private static final Logger log = LoggerFactory.getLogger(JwtProcess.class);

    // 토큰 생성
    public static String create(LoginUser loginUser) {
        log.debug("디버그 : JwtProcess create()");
        String jwtToken = JWT.create()
                .withSubject(loginUser.getUsername()) // 토큰의 제목 (아무거나 적어도 됨)
                .withExpiresAt(new Date(System.currentTimeMillis() + JwtVO.EXPIRATION_TIME))
                .withClaim("id", loginUser.getUser().getId())
                .withClaim("username", loginUser.getUser().getUsername())
                .withClaim("role", loginUser.getUser().getRoleType().name())
                .sign(Algorithm.HMAC512(JwtVO.SECRET));
        return JwtVO.TOKEN_PREFIX + jwtToken;
    }

    // 토큰 검증 (return 되는 LoginUser 객체를 강제로 시큐리티 세션에 직접 주입할 예정)
    public static LoginUser verify(String token) {
        log.debug("디버그 : JwtProcess verify()");
        DecodedJWT decodedJWT = JWT.require(Algorithm.HMAC512(JwtVO.SECRET)).build().verify(token);
        Long id = decodedJWT.getClaim("id").asLong();
        String role = decodedJWT.getClaim("role").asString();
        String username = decodedJWT.getClaim("username").asString();
        User user = User.builder().id(id).roleType(UserRoleEnum.valueOf(role)).username(username).build();
        return new LoginUser(user);
    }
}
