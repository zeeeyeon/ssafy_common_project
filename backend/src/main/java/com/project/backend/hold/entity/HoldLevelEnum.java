package com.project.backend.hold.entity;

public enum HoldLevelEnum {
    ONE(1),
    TWO(2),
    THREE(3),
    FOUR(4),
    FIVE(5),
    SIX(6),
    SEVEN(7),
    EIGHT(8),
    NINE(9),
    TEN(10),
    ELEVEN(11);

    private final int value;

    HoldLevelEnum(int value) {
        this.value = value;
    }

    public int getValue() {
        return value;
    }
}
