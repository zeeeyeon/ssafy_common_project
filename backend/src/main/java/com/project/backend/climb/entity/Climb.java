package com.project.backend.climb.entity;

import com.project.backend.climbinfo.entity.ClimbInfo;
import com.project.backend.hold.entity.Hold;
import com.project.backend.userclimb.entity.UserClimb;
import jakarta.persistence.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Entity
public class Climb {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "climb_id")
    private Long id;

    private String name;

    private String image;

    private String address;

    private BigDecimal longitude;

    private BigDecimal latitude;

    private String open;

    private String number;



    @OneToMany(mappedBy = "climb", cascade = CascadeType.ALL)
    private List<UserClimb> userClimbList = new ArrayList<>();

    @OneToMany(mappedBy = "climb", cascade = CascadeType.ALL)
    private List<ClimbInfo> climbInfoList = new ArrayList<>();

    @OneToMany(mappedBy = "climb", cascade = CascadeType.ALL)
    private List<Hold> holdList = new ArrayList<>();

}