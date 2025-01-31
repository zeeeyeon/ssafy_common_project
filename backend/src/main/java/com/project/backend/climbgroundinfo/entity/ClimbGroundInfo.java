package com.project.backend.climbgroundinfo.entity;

import com.project.backend.climbground.entity.ClimbGround;
import com.project.backend.common.entity.BaseEntity;
import com.project.backend.info.entity.Info;
import jakarta.persistence.*;
import lombok.Getter;

@Entity
@Getter
@AttributeOverride(name="Id", column=@Column(name="climbground_info_id"))
@Table(name = "climbground_info")
public class ClimbGroundInfo extends BaseEntity {

//    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
//    @Column(name = "climbground_info_id")
//    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "climbground_id")
    private ClimbGround climbGround;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "info_id")
    private Info info;
}
