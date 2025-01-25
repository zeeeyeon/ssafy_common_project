package com.project.backend.user.entity;
import jakarta.persistence.*;

@Entity
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String email;

    private String password;

    private String name;

    private String phone;

    // role
    private UserRoleEnum role;

    private String nickname;

    private String profile;

    private float height;

    private float reach;

    private int score;

    // tier
    private UserTierEnum tier;
}
