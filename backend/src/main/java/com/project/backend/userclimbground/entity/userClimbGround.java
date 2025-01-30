package com.project.backend.userclimbground.entity;

import com.project.backend.climbground.entity.ClimbGround;
import com.project.backend.userdate.entity.userDate;
import com.project.backend.user.entity.User;
import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "user_climbground")
public class userClimbGround {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_climbground_id")
    private Long id;

    private UserClimbGroundMedalEnum medal;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "climbground_id")
    private ClimbGround climbGround;

    @OneToMany(mappedBy = "userClimbGround", cascade = CascadeType.ALL)
    private List<userDate> userDateList = new ArrayList<>();

}
