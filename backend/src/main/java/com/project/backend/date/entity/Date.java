package com.project.backend.date.entity;

import com.project.backend.record.entity.Record;
import com.project.backend.userclimb.entity.UserClimb;
import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.List;

@Entity
public class Date {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "date_id")
    private Long id;


    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_climb_id")
    private UserClimb userClimb;

    @OneToMany(mappedBy = "date", cascade = CascadeType.ALL)
    private List<Record> recordList = new ArrayList<>();
}