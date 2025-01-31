package com.project.backend.record.controller;

import com.project.backend.climbground.entity.ClimbGround;
import com.project.backend.climbground.repository.ClimbGroundRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.web.webauthn.management.UserCredentialRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Optional;

@RequestMapping("/api")
@RestController
@RequiredArgsConstructor
public class RecordController {

    private final ClimbGroundRepository climbGroundRepository;

    @GetMapping("/record")
    public String hello(){
        return "Hello, ";
    }

    @GetMapping("/record2")
    public String hello2() {
        List<ClimbGround> listAll = climbGroundRepository.findAll();
        if (listAll.isEmpty()) {
            return "No Data Found";
        }
        return Optional.ofNullable(listAll.get(1).getName()).orElse("Name is Null");
    }

    @GetMapping("/records")
    public List<ClimbGround> getAllClimbGrounds() {
        return climbGroundRepository.findAll();
    }
}
