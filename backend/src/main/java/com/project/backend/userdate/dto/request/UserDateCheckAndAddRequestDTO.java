package com.project.backend.userdate.dto.request;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
@AllArgsConstructor
public class UserDateCheckAndAddRequestDTO {
    Long userId;
    Long climbGroundId;
    LocalDate date;
}
