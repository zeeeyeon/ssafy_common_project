package com.project.backend.userdate.repository;

import com.project.backend.userdate.dto.MonthlyRecordDto;
import com.project.backend.userdate.entity.UserDate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
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


    //앨범 조회
//    @Query("SELECT ud FROM UserDate ud " +
//            "JOIN FETCH ud.userClimbGround uc " +
//            "JOIN FETCH ud.climbingRecordList cr " +
//            "JOIN FETCH cr.video v " +
//            "WHERE uc.user.id = :userId " +
//            "AND ud.createdAt >= :startOfDay AND ud.createdAt < :endOfDay " +
//            "AND cr.isSuccess = :isSuccess ")
//    List<UserDate> findUserDatesByUserAndClimbGroundAndIsSuccess(Long userId, LocalDateTime startOfDay, LocalDateTime endOfDay, Boolean isSuccess);

    @Query("SELECT ud FROM UserDate ud " +
            "WHERE ud.userClimbGround.user.id = :userId " +
            "AND DATE(ud.createdAt) = :date " +
            "AND ud.isSuccess = :isSuccess")
    List<UserDate> findUserDatesByUserAndClimbGroundAndIsSuccess(
            Long userId, LocalDate date, boolean isSuccess);

}
