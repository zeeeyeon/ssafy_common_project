package com.project.backend.userdate.entity;

import com.project.backend.common.auditing.BaseEntity;
import com.project.backend.record.entity.Record;
import com.project.backend.userclimbground.entity.UserClimbGround;
import jakarta.persistence.*;
import lombok.Getter;

import java.util.HashSet;
import java.util.Set;

@Entity
@Getter
@AttributeOverride(name="Id", column=@Column(name="user_date_id"))
public class UserDate extends BaseEntity {
//    @Id
//    @GeneratedValue(strategy = GenerationType.IDENTITY)
//    @Column(name = "user_date_id")
//    private Long id;


    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_climbground_id")
    private UserClimbGround userClimbGround;

    @OneToMany(mappedBy = "userDate", cascade = CascadeType.ALL)
    private Set<Record> recordList = new HashSet<>();
}