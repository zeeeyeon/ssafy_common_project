package com.project.backend.hold.entity;

import com.project.backend.climbground.entity.ClimbGround;
import com.project.backend.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;

@Entity
@Getter
@AttributeOverride(name="Id", column=@Column(name="hold_id"))
public class Hold extends BaseEntity {
//    @Id
//    @GeneratedValue( strategy = GenerationType.IDENTITY)
//    @Column(name = "hold_id")
//    private Long id;

    @Enumerated(EnumType.STRING)
    private HoldLevelEnum level;

    @Enumerated(EnumType.STRING)
    private HoldColorEnum color;


    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "climbground_id")
    private ClimbGround climbGround;
}

