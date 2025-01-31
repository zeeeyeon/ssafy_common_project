package com.project.backend.userdate.entity;

import com.project.backend.record.entity.Record;
import com.project.backend.userclimbground.entity.UserClimbGround;
import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.List;

@Entity
public class UserDate {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_date_id")
    private Long id;


    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_climbground_id")
    private UserClimbGround userClimbGround;

    @OneToMany(mappedBy = "userDate", cascade = CascadeType.ALL)
    private List<Record> recordList = new ArrayList<>();
}