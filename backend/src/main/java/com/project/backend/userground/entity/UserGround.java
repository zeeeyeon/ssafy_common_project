package com.project.backend.userground.entity;

import com.project.backend.climb.entity.Climb;
import com.project.backend.date.entity.Date;
import com.project.backend.user.entity.User;
import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.List;

@Entity
public class UserGround {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_ground_id")
    private Long id;

    private UserClimbMedalEnum medal;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "climb_id")
    private Climb climb;

    @OneToMany(mappedBy = "userGround", cascade = CascadeType.ALL)
    private List<Date> dateList = new ArrayList<>();

}
