package com.project.backend.user.entity;

public enum UserTierEnum {
    DIAMOND(50),
    PLATINUM(35),
    GOLD(20),
    SILVER(10),
    BRONZE(1),
    UNRANK(0);

    private final int requiredScore;

    UserTierEnum(int requiredScore) {
        this.requiredScore = requiredScore;
    }

    public int getRequiredScore() {
        return requiredScore;
    }

    public static UserTierEnum getTierByScore(int score) {
        for (UserTierEnum tier : UserTierEnum.values()) {
            if (score >= tier.getRequiredScore()) {
                return tier;
            }
        }
        return UNRANK;
    }
}
