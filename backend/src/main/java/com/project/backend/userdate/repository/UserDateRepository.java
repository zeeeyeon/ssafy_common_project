package com.project.backend.userdate.repository;

import com.project.backend.userdate.dto.MonthlyRecordDto;
import com.project.backend.userdate.entity.UserDate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface UserDateRepository extends JpaRepository<UserDate, Long> {

    @Query("SELECT DISTINCT ud FROM UserDate ud " +
            "JOIN FETCH ud.userClimbGround ucg " +
            "JOIN FETCH ucg.climbGround cg " +
            "JOIN FETCH ucg.user u " +
            "WHERE ud.createdAt BETWEEN :startOfDay AND :endOfDay " +
            "AND u.id = :userId")
    Optional<UserDate> findByDateAndUserId(LocalDateTime startOfDay, LocalDateTime endOfDay, Long userId);

    @Query("SELECT COUNT(ud) FROM UserDate ud " +
            "WHERE ud.userClimbGround.Id = :userClimbGroundId " +
            "AND ud.createdAt >= :startOfDay AND ud.createdAt < :endOfDay")
    int countVisits(LocalDateTime startOfDay, LocalDateTime endOfDay, Long userClimbGroundId);


    @Query("SELECT new com.project.backend.userdate.dto.MonthlyRecordDto(" +
            "DAY(ud.createdAt), " +
            "COUNT(r)) " +
            "FROM UserDate ud " +
            "JOIN ud.userClimbGround ucg " +
            "JOIN ud.climbingRecordList r " +
            "WHERE ucg.user.id = :userId " +
            "AND YEAR(ud.createdAt) = :year " +
            "AND MONTH(ud.createdAt) = :month " +
            "GROUP BY DAY(ud.createdAt)")
    List<MonthlyRecordDto> findMonthlyRecords(@Param("year") int year, @Param("month") int month, @Param("userId") Long userId);

    @Query("SELECT ud FROM UserDate ud " +
            "JOIN ud.userClimbGround uc " +
            "WHERE uc.user.id = :userId " +
            "AND uc.climbGround.Id = :climbGroundId " +
            "AND ud.createdAt >= :startOfDay AND ud.createdAt < :endOfDay ")
    Optional<UserDate> findUserDateByUserAndClimbgroundAndDate(
        Long userId, Long climbGroundId, LocalDateTime startOfDay, LocalDateTime endOfDay
    );
}
