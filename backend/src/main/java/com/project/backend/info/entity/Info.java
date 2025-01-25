package com.project.backend.info.entity;

import com.project.backend.climbinfo.entity.ClimbInfo;
import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.List;

@Entity
public class Info {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "info_id")
    private Long id;

    private String info;

    @OneToMany(mappedBy = "info", cascade = CascadeType.ALL)
    private List<ClimbInfo> climbInfoList = new ArrayList<>();
}