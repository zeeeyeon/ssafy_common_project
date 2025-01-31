package com.project.backend.user.entity;

import lombok.Setter;

import org.springframework.data.annotation.Id;
import org.springframework.data.redis.core.RedisHash;
import java.io.Serializable;
import java.util.Date;

@Setter
@RedisHash("refreshToken")
public class UserRefreshToken implements Serializable {

    @Id
    private String userName;
    private String refreshToken;
    private Date expirationDate;
    private String authorities; // 필요에 따라 선택

}