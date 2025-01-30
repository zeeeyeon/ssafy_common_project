package com.project.backend.climbground.entity;

import com.project.backend.climbgroundinfo.entity.ClimbGroundInfo;
import com.project.backend.hold.entity.Hold;
import com.project.backend.userclimbground.entity.userClimbGround;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Entity
@Getter
@NoArgsConstructor
@Table(name = "climbground")
public class ClimbGround {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "climbground_id")
    private Long id;


    @Column(nullable = false)
    private String name;

    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String image;

    @Column(nullable = false)
    private String address;

//    이건 일일이 찾아넣기 귀찮은데..
    @Column(precision=13, scale=9,nullable = true)
    private BigDecimal longitude;

    @Column(precision=12, scale=9, nullable = true)
    private BigDecimal latitude;

    private String open;

    private String number;

    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String sns_url;

    @OneToMany(mappedBy = "climbGround", cascade = CascadeType.ALL)
    private List<userClimbGround> userClimbGroundList = new ArrayList<>();

    @OneToMany(mappedBy = "climbGround", cascade = CascadeType.ALL , fetch = FetchType.LAZY)
    private List<ClimbGroundInfo> climbGroundInfoList = new ArrayList<>();

    @OneToMany(mappedBy = "climbGround", cascade = CascadeType.ALL ,fetch = FetchType.LAZY)
    private List<Hold> holdList = new ArrayList<>();

}