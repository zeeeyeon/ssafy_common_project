package com.project.backend.record.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class RecordController {

    @GetMapping("/api/record")
    public String hello(){
        return "Hello, ~~~";
    }
}
