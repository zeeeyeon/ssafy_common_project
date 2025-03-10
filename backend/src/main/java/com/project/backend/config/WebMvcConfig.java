package com.project.backend.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOrigins("https://i12e206.p.ssafy.io", "http://localhost:8080", "http://localhost:65237")
                .allowedMethods("*")
                .allowCredentials(true)
                .allowedHeaders("*");
    }
}