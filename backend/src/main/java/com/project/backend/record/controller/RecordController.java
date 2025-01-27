package com.project.backend.record.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController("/record")
public class RecordController {

    @GetMapping()
    public String hello(){
        return "Hello, test code #1";
    }
}
