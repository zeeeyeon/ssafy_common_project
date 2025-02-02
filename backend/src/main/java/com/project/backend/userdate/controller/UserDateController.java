package com.project.backend.userdate.controller;

import com.project.backend.userdate.dto.response.DailyClimbingRecordResponse;
import com.project.backend.userdate.service.UserDateService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/record")
@RequiredArgsConstructor
public class UserDateController {
    private final UserDateService userDateService;

    // user 가져오는 방법 물어보기
    @GetMapping("/daily/{userId}")
    public ResponseEntity<DailyClimbingRecordResponse> getDailyRecord (
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate selectedDate,
            @PathVariable Long userId) {

        DailyClimbingRecordResponse dailyRecord = userDateService.getDailyRecord(selectedDate, userId);
        return null;
    }

//    @GetMapping("/test")
//    public void test(@AuthenticationPrincipal UserPrincipal userPrincipal) throws JsonProcessingException {
//        ObjectMapper objectMapper = new ObjectMapper();
//        System.out.println(objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(userPrincipal));
//    }

}
