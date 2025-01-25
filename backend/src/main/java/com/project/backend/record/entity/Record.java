package com.project.backend.record.entity;

import com.project.backend.date.entity.Date;
import com.project.backend.hold.entity.Hold;
import com.project.backend.video.entity.Video;
import jakarta.persistence.*;

@Entity
public class Record {

    @Id
    @GeneratedValue( strategy = GenerationType.IDENTITY )
    @Column(name = "record_id")
    private Long id;
    private boolean isSuccess;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "date_id")
    private Date date;

    @OneToOne(mappedBy = "record", cascade = CascadeType.ALL)
    private Video video;

    // 단반향이니까 hold entity에는 따로 안넣어도 되지 않나??
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "hold_id")
    private Hold hold;
}
