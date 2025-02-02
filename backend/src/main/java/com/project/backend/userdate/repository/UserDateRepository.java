package com.project.backend.userdate.repository;

import com.project.backend.userdate.entity.UserDate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDateTime;
import java.util.Optional;

public interface UserDateRepository extends JpaRepository<UserDate, Long> {

    @Query("SELECT ud FROM UserDate ud " +
            "JOIN FETCH ud.userClimbGround ucg " +
            "JOIN FETCH ucg.climbGround cg " +
            "WHERE ud.createdAt >= :startOfDay AND ud.createdAt < :endOfDay " +
            "AND ucg.user.id = :userId")
    Optional<UserDate> findByDateAndUserId(LocalDateTime startOfDay, LocalDateTime endOfDay, Long userId);

    @Query("SELECT COUNT(ud) FROM UserDate ud " +
            "WHERE ud.userClimbGround.Id = :userClimbGroundId " +
            "AND ud.createdAt >= :startOfDay AND ud.createdAt < :endOfDay")
    int countVisits(LocalDateTime startOfDay, LocalDateTime endOfDay, Long userClimbGroundId);

}
