package com.project.backend.user.entity;
import com.project.backend.record.entity.ClimbingRecord;
import com.project.backend.user.dto.request.UserInfoRequestDto;
import com.project.backend.userclimbground.entity.UserClimbGround;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;
import net.minidev.json.annotate.JsonIgnore;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Builder
@Table(name = "user",
        uniqueConstraints = {
                @UniqueConstraint(name = "UK_USER_EMAIL", columnNames = "email"),
                @UniqueConstraint(name = "UK_USER_NICKNAME", columnNames = "nickname")
        }
)
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    @JsonIgnore
    private Long id;

    @NotNull
    @Column(unique = true)
    private String email;

    @JsonIgnore
    private String password;

    @Column(length = 100)
    @NotNull
    @Size(max = 100)
    private String username;

    // 소셜 로그인 회원용 (카카오의 고유 ID 등)
    private Long socialId;

    @NotNull
    private String phone;

    @NotNull
    @Column(unique = true)
    private String nickname;

    private String profile;

    private Float height;

    private Float reach;

    private LocalDateTime startDate;
    private LocalDateTime createDate;
    private LocalDateTime updateDate;

    @Column(length = 512)
    @Size(max = 512)
    private String profileImageUrl;

    private int score;

    // tier
    @Enumerated(EnumType.STRING)
    private UserTierEnum tier;

    @Builder.Default
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<UserClimbGround> userClimbGroundList = new ArrayList<>();

    @Builder.Default
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<ClimbingRecord> userClimbingRecordList = new ArrayList<>();


    @Builder
    public User(Long id, String username, String email, String nickname, int score, UserTierEnum tier) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.nickname = nickname;
        this.score = score;
        this.tier = tier;
    }

    public User setUserInfoRequestDto(UserInfoRequestDto requestDto) {
        this.nickname = requestDto.getNickname() != null ? requestDto.getNickname() : this.nickname;
        this.height = requestDto.getHeight() != null ? requestDto.getHeight() : this.height;
        this.reach = requestDto.getReach() != null ? requestDto.getReach() : this.reach;
        this.startDate = requestDto.getStartDate() != null ? requestDto.getStartDate() : this.startDate;
        return this;
    }

}
