package com.project.backend.date.entity;

import com.project.backend.record.entity.Record;
import com.project.backend.userground.entity.UserGround;
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
    @JoinColumn(name = "user_ground_id")
    private UserGround userGround;

    @OneToMany(mappedBy = "date", cascade = CascadeType.ALL)
    private List<Record> recordList = new ArrayList<>();
}