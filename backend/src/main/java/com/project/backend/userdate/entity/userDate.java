package com.project.backend.userdate.entity;

import com.project.backend.record.entity.Record;
import jakarta.persistence.*;
import com.project.backend.userclimbground.entity.userClimbGround;

import java.util.ArrayList;
import java.util.List;

@Entity
public class userDate {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "date_id")
    private Long id;


    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_climbground_id")
    private userClimbGround userClimbGround;

    @OneToMany(mappedBy = "userDate", cascade = CascadeType.ALL)
    private List<Record> recordList = new ArrayList<>();
}