package com.project.backend.userclimbground.entity;

import com.project.backend.climbground.entity.ClimbGround;
import com.project.backend.common.auditing.BaseEntity;
import com.project.backend.user.entity.User;
import com.project.backend.user.entity.UserProviderEnum;
import com.project.backend.user.entity.UserRoleEnum;
import com.project.backend.userdate.entity.UserDate;
import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.HashSet;
import java.util.Set;

@Entity
@Getter
@Setter
@Table(name = "user_climbground")
@AttributeOverride(name="Id", column=@Column(name="user_climbground_id"))
@NoArgsConstructor
public class UserClimbGround extends BaseEntity {

//    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
//    @Column(name = "user_climbground_id")
//    private Long id;

    @Enumerated(EnumType.STRING)
    private UserClimbGroundMedalEnum medal;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "climbground_id")
    private ClimbGround climbGround;

    @OneToMany(mappedBy = "userClimbGround", cascade = CascadeType.ALL)
    private Set<UserDate> userDateList = new HashSet<>();


    @Builder
    public UserClimbGround(User user, ClimbGround climbGround, UserClimbGroundMedalEnum medal) {
        this.user = user;
        this.climbGround = climbGround;
        this.medal = medal;
    }

    public void updateMedal(UserClimbGroundMedalEnum medal) {
        this.medal = medal;
    }
}
