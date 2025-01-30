package com.project.backend.climb.center.entity;

import com.project.backend.climbinfo.entity.ClimbInfo;
import com.project.backend.hold.entity.Hold;
import com.project.backend.userclimb.entity.UserClimb;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
@NoArgsConstructor
public class Climb {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "climb_id")
    private Long id;


    @Column(nullable = false)
    private String name;

    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String image;

    @Column(nullable = false)
    private String address;

    //이건 일일이 찾아넣기 귀찮은데..
//    @Column(nullable = false)
//    private BigDecimal longitude;
//
//    @Column(nullable = false)
//    private BigDecimal latitude;

    private String open;

    private String number;

    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String sns_url;

    @OneToMany(mappedBy = "climb", cascade = CascadeType.ALL)
    private List<UserClimb> userClimbList = new ArrayList<>();

    @OneToMany(mappedBy = "climb", cascade = CascadeType.ALL)
    private List<ClimbInfo> climbInfoList = new ArrayList<>();

    @OneToMany(mappedBy = "climb", cascade = CascadeType.ALL)
    private List<Hold> holdList = new ArrayList<>();

}