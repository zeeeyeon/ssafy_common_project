package com.project.backend.user.entity;
import com.project.backend.record.entity.Record;
import com.project.backend.userclimbground.entity.userClimbGround;
import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.List;

@Entity
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
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

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<userClimbGround> userClimbGroundList = new ArrayList<>();

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<Record> userRecordList  = new ArrayList<>();



}
