package com.project.backend.climbinfo.entity;

import com.project.backend.climb.entity.Climb;
import com.project.backend.info.entity.Info;
import jakarta.persistence.*;

@Entity
public class ClimbInfo {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "climb_info_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "climb_id")
    private Climb climb;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "info_id")
    private Info info;
}
