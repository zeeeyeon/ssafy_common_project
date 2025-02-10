package com.project.backend.userclimbground.entity;

import lombok.Getter;

@Getter
public enum UserClimbGroundMedalEnum {
    GOLD(5),
    SILVER(3),
    BRONZE(1),
    NONE(0);

    private final int score;

    UserClimbGroundMedalEnum(int score) {
        this.score = score;
    }

}
