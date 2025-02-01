package com.project.backend.userdate.controller;

import com.project.backend.userdate.dto.response.DailyClimbingRecordResponse;
import com.project.backend.userdate.service.UserDateService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/record")
@RequiredArgsConstructor
public class UserDateController {
    private final UserDateService userDateService;

    // user 가져오는 방법 물어보기
    @GetMapping("/daily")
    public ResponseEntity<DailyClimbingRecordResponse> getDailyRecord (
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate selectedDate
            /*@AuthenticationPrincipal UserPrincipal userPrincipal*/) {


        // response<T> 물어보기
        return null;
    }

}
