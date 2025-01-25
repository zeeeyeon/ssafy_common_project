package com.project.backend.hold.entity;

import com.project.backend.climb.entity.Climb;
import jakarta.persistence.*;

@Entity
public class Hold {
    @Id
    @GeneratedValue( strategy = GenerationType.IDENTITY)
    @Column(name = "hold_id")
    private Long id;
    private HoldLevelEnum level;
    private HoldColorEnum color;


    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "climb_id")
    private Climb climb;
}

