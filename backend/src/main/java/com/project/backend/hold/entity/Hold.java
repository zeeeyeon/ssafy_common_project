package com.project.backend.hold.entity;

import com.project.backend.climbground.entity.ClimbGround;
import jakarta.persistence.*;
import lombok.Getter;

@Entity
@Getter
public class Hold {
    @Id
    @GeneratedValue( strategy = GenerationType.IDENTITY)
    @Column(name = "hold_id")
    private Long id;

    @Enumerated(EnumType.STRING)
    private HoldLevelEnum level;

    @Enumerated(EnumType.STRING)
    private HoldColorEnum color;


    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "climbground_id")
    private ClimbGround climbGround;
}

