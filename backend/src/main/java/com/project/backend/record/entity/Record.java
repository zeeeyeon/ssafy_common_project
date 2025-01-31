package com.project.backend.record.entity;

import com.project.backend.user.entity.User;
import com.project.backend.userdate.entity.userDate;
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
    @JoinColumn(name = "user_date_id")
    private userDate userDate;

    @OneToOne(mappedBy = "record", cascade = CascadeType.ALL)
    private Video video;

    // 단반향이니까 hold entity에는 따로 안넣어도 되지 않나??
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "hold_id")
    private Hold hold;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;


}
