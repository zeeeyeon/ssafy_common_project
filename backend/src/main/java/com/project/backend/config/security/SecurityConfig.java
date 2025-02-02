package com.project.backend.config.security;

import com.project.backend.config.properties.AppProperties;
import com.project.backend.config.properties.CorsProperties;
import com.project.backend.oauth.exception.RestAuthenticationEntryPoint;
import com.project.backend.oauth.filter.TokenAuthenticationFilter;
import com.project.backend.oauth.handler.OAuth2AuthenticationFailureHandler;
import com.project.backend.oauth.handler.OAuth2AuthenticationSuccessHandler;
import com.project.backend.oauth.handler.TokenAccessDeniedHandler;
import com.project.backend.oauth.repository.OAuth2AuthorizationRequestBasedOnCookieRepository;
import com.project.backend.oauth.service.CustomOAuth2UserService;
import com.project.backend.oauth.service.CustomUserDetailsService;
import com.project.backend.oauth.token.AuthTokenProvider;
import com.project.backend.user.entity.UserRoleEnum;
import com.project.backend.user.jwt.JwtAuthenticationFilter;
import com.project.backend.user.jwt.JwtAuthorizationFilter;
import com.project.backend.user.repository.redis.UserRefreshTokenRepository;
import com.project.backend.user.repository.jpa.UserRepository;
import com.project.backend.user.util.CustomResponseUtil;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.security.servlet.PathRequest;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.annotation.web.configurers.HeadersConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsUtils;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

@Configuration
@RequiredArgsConstructor
@EnableWebSecurity
@EnableConfigurationProperties(CorsProperties.class)
public class SecurityConfig {

    private final UserRepository userRepository;  // 필드 추가
    private final CorsProperties corsProperties;
    private final AppProperties appProperties;
    private final AuthTokenProvider tokenProvider;
    private final CustomUserDetailsService userDetailsService;
    private final CustomOAuth2UserService oAuth2UserService;
    private final TokenAccessDeniedHandler tokenAccessDeniedHandler;
    private final UserRefreshTokenRepository userRefreshTokenRepository;
    private final Logger log = LoggerFactory.getLogger(getClass());

    // JWT 필터 등록이 필요함
    public static class CustomSecurityFilterManager extends AbstractHttpConfigurer<CustomSecurityFilterManager, HttpSecurity> {
        public void configure(HttpSecurity builder) throws Exception {
            AuthenticationManager authenticationManager = builder.getSharedObject(AuthenticationManager.class);
            builder.addFilter(new JwtAuthenticationFilter(authenticationManager));
            builder.addFilter(new JwtAuthorizationFilter(authenticationManager));
            super.configure(builder);
        }
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        log.debug("디버그 : filterChain 빈 등록됨");

        // 1. 헤더 설정: iframe 사용 제한 해제
        http.headers(headers ->
                headers.frameOptions(HeadersConfigurer.FrameOptionsConfig::disable)
        );

        // 2. CORS 설정 (여기서 corsConfigurationSource() 메서드가 존재하는지 확인)
        http.cors(cors ->
                cors.configurationSource(corsConfigurationSource())
        );

        // 3. CSRF 비활성화
        http.csrf(AbstractHttpConfigurer::disable);

        // 4. 세션 관리를 Stateless로 설정
        http.sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
        );

        // 5. formLogin 및 httpBasic 비활성화
        http.formLogin(AbstractHttpConfigurer::disable);
        http.httpBasic(AbstractHttpConfigurer::disable);

        // 6. 추가 필터: 커스텀 SecurityFilterManager 적용
        http.with(new CustomSecurityFilterManager(), CustomSecurityFilterManager::getClass);

        // 7. 예외 처리: 인증 실패 및 권한 부족 시 응답 메시지 설정
        http.exceptionHandling(exception -> exception
                .authenticationEntryPoint((request, response, authException) -> {
                    // 인증 실패 시 메시지 전송
                    CustomResponseUtil.fail(response, "로그인을 진행해 주세요", HttpStatus.UNAUTHORIZED);
                })
                .accessDeniedHandler((request, response, e) -> {
                    // 권한 부족 시 메시지 전송
                    CustomResponseUtil.fail(response, "권한이 없습니다", HttpStatus.FORBIDDEN);
                })
        );

        // 8. OAuth2 로그인 설정 (기존 설정 유지)
        http.oauth2Login(oauth2 -> oauth2
                .authorizationEndpoint(authorization -> authorization
                        .baseUri("/oauth2/authorization")
                        .authorizationRequestRepository(oAuth2AuthorizationRequestBasedOnCookieRepository())
                )
                .redirectionEndpoint(redirection -> redirection
                        .baseUri("/login/oauth2/code/*")
                )
                .userInfoEndpoint(userInfo -> userInfo
                        .userService(oAuth2UserService)
                )
                .successHandler(oAuth2AuthenticationSuccessHandler())
                .failureHandler(oAuth2AuthenticationFailureHandler())
        );

        // 9. 요청별 권한 설정
        http.authorizeHttpRequests(authorize -> authorize
                // preflight 요청 허용 (CORS 관련)
                .requestMatchers(CorsUtils::isPreFlightRequest).permitAll()
                // 정적 자원 접근 허용 (Spring Boot 기본 정적 자원 경로)
                .requestMatchers(PathRequest.toStaticResources().atCommonLocations()).permitAll()
                // 회원가입 API는 인증 없이 접근 허용
                .requestMatchers("/api/user/signup").permitAll()
                // /api/user/** 경로는 인증된 사용자만 접근
                .requestMatchers("/api/user/**").authenticated()
                // /api/admin/** 경로는 ADMIN 권한 사용자만 접근 (UserRoleEnum.ADMIN의 값에 따라 ROLE_ 접두어가 자동으로 붙을 수 있음)
//                .requestMatchers("/api/admin/**").hasRole(String.valueOf(UserRoleEnum.ADMIN))
                // 그 외 모든 요청은 허용
                .anyRequest().permitAll()
        );

        // 10. 토큰 인증 필터를 UsernamePasswordAuthenticationFilter 이전에 추가
        http.addFilterBefore(tokenAuthenticationFilter(), UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public AuthenticationManager authManager(HttpSecurity http) throws Exception {
        AuthenticationManagerBuilder authenticationManagerBuilder =
                http.getSharedObject(AuthenticationManagerBuilder.class);
        authenticationManagerBuilder.userDetailsService(userDetailsService)
                .passwordEncoder(passwordEncoder());
        return authenticationManagerBuilder.build();
    }

    @Bean
    public BCryptPasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public TokenAuthenticationFilter tokenAuthenticationFilter() {
        return new TokenAuthenticationFilter(tokenProvider);
    }

    @Bean
    public OAuth2AuthorizationRequestBasedOnCookieRepository oAuth2AuthorizationRequestBasedOnCookieRepository() {
        return new OAuth2AuthorizationRequestBasedOnCookieRepository();
    }

    @Bean
    public OAuth2AuthenticationSuccessHandler oAuth2AuthenticationSuccessHandler() {
        return new OAuth2AuthenticationSuccessHandler(
                tokenProvider,
                appProperties,
                userRefreshTokenRepository,
                oAuth2AuthorizationRequestBasedOnCookieRepository()
        );
    }

    @Bean
    public OAuth2AuthenticationFailureHandler oAuth2AuthenticationFailureHandler() {
        return new OAuth2AuthenticationFailureHandler(oAuth2AuthorizationRequestBasedOnCookieRepository());
    }

    @Bean
    public UrlBasedCorsConfigurationSource corsConfigurationSource() {
        UrlBasedCorsConfigurationSource corsConfigSource = new UrlBasedCorsConfigurationSource();

        CorsConfiguration corsConfig = new CorsConfiguration();
        corsConfig.setAllowedHeaders(Arrays.asList(corsProperties.getAllowedHeaders().split(",")));
        corsConfig.setAllowedMethods(Arrays.asList(corsProperties.getAllowedMethods().split(",")));
        corsConfig.setAllowedOrigins(Arrays.asList(corsProperties.getAllowedOrigins().split(",")));
        corsConfig.setAllowCredentials(true);
        corsConfig.setMaxAge(corsConfig.getMaxAge());

        corsConfigSource.registerCorsConfiguration("/**", corsConfig);
        return corsConfigSource;
    }
}
