package com.project.backend.record.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class RecordController {

    @GetMapping("/test")
    public ResponseEntity<String> test() {
        return ResponseEntity.ok("CORS 테스트 성공");

    }
}
