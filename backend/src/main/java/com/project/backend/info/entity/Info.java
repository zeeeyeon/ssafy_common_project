package com.project.backend.info.entity;

import com.project.backend.climbinfo.entity.ClimbGroundInfo;
import jakarta.persistence.*;
import lombok.Getter;

import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
public class Info {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "info_id")
    private Long id;

    private String info;

    @OneToMany(mappedBy = "info", cascade = CascadeType.ALL)
    private List<ClimbGroundInfo> climbGroundInfoList = new ArrayList<>();
}