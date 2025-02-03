package com.project.backend.user.jwt;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.project.backend.user.auth.CustomUserDetails;
import com.project.backend.user.dto.LoginRequestDto;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.InternalAuthenticationServiceException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;

import java.io.IOException;


public class JwtAuthenticationFilter extends UsernamePasswordAuthenticationFilter {
    private final Logger log = LoggerFactory.getLogger(getClass());
    private final AuthenticationManager authenticationManager;
    private final ObjectMapper objectMapper;

    public JwtAuthenticationFilter(AuthenticationManager authenticationManager) {
        this.authenticationManager = authenticationManager;
        this.objectMapper = new ObjectMapper();
        setFilterProcessesUrl("/api/login");
    }

    @Override
    public Authentication attemptAuthentication(HttpServletRequest request, HttpServletResponse response)
            throws AuthenticationException {
        log.debug("디버그 : attemptAuthentication 시작");

        try {
            LoginRequestDto loginReqDto = objectMapper.readValue(request.getInputStream(), LoginRequestDto.class);

            // 기본 유효성 검사
            if (loginReqDto.getEmail() == null || loginReqDto.getPassword() == null) {
                throw new BadCredentialsException("아이디와 비밀번호를 모두 입력해주세요.");
            }

            UsernamePasswordAuthenticationToken authenticationToken = new UsernamePasswordAuthenticationToken(
                    loginReqDto.getEmail(),
                    loginReqDto.getPassword());

            // 추가 요청 데이터 설정
            authenticationToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

            return authenticationManager.authenticate(authenticationToken);

        } catch (IOException e) {
            log.error("로그인 요청 처리 중 오류 발생: ", e);
            throw new InternalAuthenticationServiceException("로그인 처리 중 오류가 발생했습니다.", e);
        }
    }

    @Override
    protected void successfulAuthentication(HttpServletRequest request, HttpServletResponse response,
                                            FilterChain chain, Authentication authResult) throws IOException, ServletException {
        CustomUserDetails userDetails = (CustomUserDetails) authResult.getPrincipal();
        String token = JwtProcess.create(userDetails);

        response.addHeader("Authorization", token);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // 필요 시 상태 코드와 메시지만 반환 (본문에는 아무 내용도 포함하지 않음)
        response.setStatus(HttpServletResponse.SC_OK);
        response.getWriter().flush();  // 응답을 즉시 클라이언트로 전송
    }

}