package com.project.backend.oauth.handler;


import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerExceptionResolver;

import java.io.IOException;
import java.util.List;
import java.util.Objects;

@Component
public class TokenAccessDeniedHandler implements AccessDeniedHandler {

    private final List<HandlerExceptionResolver> resolvers;

    public TokenAccessDeniedHandler(List<HandlerExceptionResolver> resolvers) {
        this.resolvers = resolvers;
    }

    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response,
                       AccessDeniedException accessDeniedException) throws IOException {
        // resolvers 중에서 원하는 resolver를 선택하여 사용
        resolvers.stream()
                .filter(Objects::nonNull)
                .findFirst()
                .ifPresent(resolver ->
                        resolver.resolveException(request, response, null, accessDeniedException));
    }
}
