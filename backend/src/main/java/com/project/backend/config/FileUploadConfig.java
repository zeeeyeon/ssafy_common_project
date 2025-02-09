package com.project.backend.config;
import org.springframework.boot.web.servlet.MultipartConfigFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.unit.DataSize;

import jakarta.servlet.MultipartConfigElement;

@Configuration
public class FileUploadConfig {
    @Bean
    public MultipartConfigElement multipartConfigElement() {
        MultipartConfigFactory factory = new MultipartConfigFactory();
        factory.setMaxFileSize(DataSize.ofGigabytes(10)); // 10GB 설정
        factory.setMaxRequestSize(DataSize.ofGigabytes(10)); // 10GB 설정
        return factory.createMultipartConfig();
    }
}
