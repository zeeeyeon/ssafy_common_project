package com.project.backend.climbground.entity;

import com.project.backend.climbgroundinfo.entity.ClimbGroundInfo;
import com.project.backend.common.auditing.BaseEntity;
import com.project.backend.hold.entity.Hold;
import com.project.backend.userclimbground.entity.UserClimbGround;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
@NoArgsConstructor
@AttributeOverride(name="Id", column=@Column(name="climbground_id")) //baseEntity에서 공통으로 관리해서 다른 이름 쓸려면 override 해야함
@Table(name = "climbground")
public class ClimbGround extends BaseEntity {
//    @Id
//    @GeneratedValue(strategy = GenerationType.IDENTITY)
//    @Column(name = "climbground_id")
//    private Long id;


    @Column(nullable = false)
    private String name;

    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String image;

    @Column(nullable = false)
    private String address;

//    이건 일일이 찾아넣기 귀찮은데..
//    @Column(precision=13, scale=9,nullable = true)
    private double longitude;

//    @Column(precision=12, scale=9, nullable = true)
    private double latitude;

    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String open;

    private String number;

    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String sns_url;

    @OneToMany(mappedBy = "climbGround", cascade = CascadeType.ALL)
    private List<UserClimbGround> userClimbGroundList = new ArrayList<>();

    @OneToMany(mappedBy = "climbGround", cascade = CascadeType.ALL , fetch = FetchType.LAZY)
    private List<ClimbGroundInfo> climbGroundInfoList = new ArrayList<>();

    @OneToMany(mappedBy = "climbGround", cascade = CascadeType.ALL ,fetch = FetchType.LAZY)
    private List<Hold> holdList = new ArrayList<>();

}