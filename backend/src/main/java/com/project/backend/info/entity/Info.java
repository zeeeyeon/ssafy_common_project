package com.project.backend.info.entity;

import com.project.backend.climbgroundinfo.entity.ClimbGroundInfo;
import com.project.backend.common.auditing.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;

import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
@AttributeOverride(name="Id", column=@Column(name="info_id"))
public class Info extends BaseEntity {

//    @Id
//    @GeneratedValue(strategy = GenerationType.IDENTITY)
//    @Column(name = "info_id")
//    private Long id;

    private String info;

    @OneToMany(mappedBy = "info", cascade = CascadeType.ALL)
    private List<ClimbGroundInfo> climbGroundInfoList = new ArrayList<>();
}