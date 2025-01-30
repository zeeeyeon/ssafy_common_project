package com.project.backend.user.repository.redis;

import com.project.backend.user.entity.UserRefreshToken;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRefreshTokenRepository extends CrudRepository<UserRefreshToken, String> {
    Optional<UserRefreshToken> findByUserName(String userName);
    UserRefreshToken findByUserNameAndRefreshToken(String userName, String refreshToken);
}

