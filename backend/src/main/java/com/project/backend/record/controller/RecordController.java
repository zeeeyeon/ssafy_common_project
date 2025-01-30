package com.project.backend.record.controller;

import com.project.backend.climbground.entity.ClimbGround;
import com.project.backend.climbground.repository.ClimbGroundRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.web.webauthn.management.UserCredentialRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class RecordController {

    private final ClimbGroundRepository climbGroundRepository;

    @GetMapping("/api/record")
    public String hello(){
        return "Hello, test code #1";
    }

    @GetMapping("/api/record2")
    public String hello2(){
        List<ClimbGround> listAll = climbGroundRepository.findAll();
        System.out.println("1111111");
        return listAll.toString();
    }
}
