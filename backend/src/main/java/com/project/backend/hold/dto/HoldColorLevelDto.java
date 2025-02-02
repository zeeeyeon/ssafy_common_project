package com.project.backend.hold.dto;

import com.project.backend.hold.entity.HoldColorEnum;
import com.project.backend.hold.entity.HoldLevelEnum;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class HoldColorLevelDto {
    private HoldColorEnum color;
    private HoldLevelEnum level;
}
