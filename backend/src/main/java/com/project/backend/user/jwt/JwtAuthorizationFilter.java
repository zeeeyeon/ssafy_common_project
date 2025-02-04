package com.project.backend.user.jwt;

import com.project.backend.oauth.token.AuthToken;
import com.project.backend.oauth.token.AuthTokenProvider;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.www.BasicAuthenticationFilter;

import java.io.IOException;

/**
 * 모든 주소에서 동작함. (토큰 검증)
 */


public class JwtAuthorizationFilter extends BasicAuthenticationFilter {
    private static final Logger log = LoggerFactory.getLogger(JwtAuthorizationFilter.class);
    private final AuthTokenProvider authTokenProvider;

    public JwtAuthorizationFilter(AuthenticationManager authenticationManager, AuthTokenProvider authTokenProvider) {
        super(authenticationManager);
        this.authTokenProvider = authTokenProvider;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        log.debug("디버그 : JwtAuthorizationFilter doFilterInternal()");

        String header = request.getHeader(JwtVO.HEADER);
        if (header != null && header.startsWith(JwtVO.TOKEN_PREFIX)) {
            String token = header.replace(JwtVO.TOKEN_PREFIX, "");
            AuthToken authToken = authTokenProvider.convertAuthToken(token);

            if (authToken.validate()) {
                Authentication authentication = authTokenProvider.getAuthentication(authToken);
                SecurityContextHolder.getContext().setAuthentication(authentication);
                log.debug("디버그 : Jwt 토큰 검증 성공");
            } else {
                log.error("디버그 : Jwt 토큰 검증 실패");
            }
        }
        chain.doFilter(request, response);
    }
}
