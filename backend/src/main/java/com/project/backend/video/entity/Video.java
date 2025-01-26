package com.project.backend.video.entity;

import com.project.backend.date.entity.Date;
import com.project.backend.record.entity.Record;
import com.project.backend.user.entity.User;
import jakarta.persistence.*;

@Entity
public class Video {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "video_id")
    private Long id;

    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String url;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "record_id")
    private Record record;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;
}