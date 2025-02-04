package com.project.backend.userdate.dto.response;


import com.project.backend.hold.entity.Hold;
import com.project.backend.userdate.entity.UserDate;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class UserDateCheckAndAddResponseDTO {

    private Long userDateId;
    private String name;
    private List<Hold> holds;

}
