package com.project.backend.video.entity;

import com.project.backend.common.auditing.BaseEntity;
import com.project.backend.record.entity.Record;
import jakarta.persistence.*;
import lombok.Getter;

@Getter
@Entity
@AttributeOverride(name="Id", column=@Column(name="video_id"))
public class Video extends BaseEntity {
//    @Id
//    @GeneratedValue(strategy = GenerationType.IDENTITY)
//    @Column(name = "video_id")
//    private Long id;

    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String url;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "record_id")
    private Record record;

}