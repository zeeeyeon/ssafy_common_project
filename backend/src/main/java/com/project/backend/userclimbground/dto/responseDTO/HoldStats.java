package com.project.backend.userclimbground.dto.responseDTO;

import com.project.backend.hold.entity.HoldColorEnum;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class HoldStats {
    private HoldColorEnum color;
    private int tryCount;
    private int success;
}
