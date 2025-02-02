package com.project.backend.userclimbground.repository;

import com.project.backend.userclimbground.entity.UserClimbGround;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDate;
import java.util.List;

public interface UserClimbGroundRepository extends JpaRepository<UserClimbGround, Long> {

    // 년별 통계 기록 조회
    @Query("SELECT uc FROM UserClimbGround uc " +
            "LEFT JOIN FETCH uc.user " +
            "LEFT JOIN FETCH uc.climbGround " +
            "LEFT JOIN FETCH uc.userDateList ud " +
            "LEFT JOIN FETCH ud.recordList r " +
            "LEFT JOIN FETCH r.hold h " +
            "WHERE r.user.id = :userId " +
            "AND FUNCTION('YEAR', ud.createdAt) = :year")
    List<UserClimbGround> findClimbRecordsByUserIdAndYear(Long userId, int year);

    // 월별 통계 기록 조회
    @Query("SELECT uc FROM UserClimbGround uc " +
            "LEFT JOIN FETCH uc.user " +
            "LEFT JOIN FETCH uc.climbGround " +
            "LEFT JOIN FETCH uc.userDateList ud " +
            "LEFT JOIN FETCH ud.recordList r " +
            "LEFT JOIN FETCH r.hold h " +
            "WHERE r.user.id = :userId " +
            "AND YEAR(ud.createdAt) = :year " +
            "AND MONTH(ud.createdAt) = :month")
    List<UserClimbGround> findClimbRecordsByUserIdAndMonth(Long userId, int year, int month);

    // 주별 기록 조회
    @Query("SELECT uc FROM UserClimbGround uc " +
            "LEFT JOIN FETCH uc.user " +
            "LEFT JOIN FETCH uc.climbGround " +
            "LEFT JOIN FETCH uc.userDateList ud " +
            "LEFT JOIN FETCH ud.recordList r " +
            "LEFT JOIN FETCH r.hold h " +
            "WHERE r.user.id = :userId " +
            "AND YEAR(ud.createdAt) = :year " +
            "AND WEEK(ud.createdAt) = :week")
    List<UserClimbGround> findClimbRecordsByUserIdAndWeek(Long userId,int year, int week);

    // 일별 기록 조회
    @Query("SELECT uc FROM UserClimbGround uc " +
            "LEFT JOIN FETCH uc.user " +
            "LEFT JOIN FETCH uc.climbGround " +
            "LEFT JOIN FETCH uc.userDateList ud " +
            "LEFT JOIN FETCH ud.recordList r " +
            "LEFT JOIN FETCH r.hold h " +
            "WHERE r.user.id = :userId " +
            "AND YEAR(ud.createdAt) = :year " +
            "AND MONTH(ud.createdAt) = :month " +
            "AND DAY(ud.createdAt) = :day")
    List<UserClimbGround> findClimbRecordsByUserIdAndDay(Long userId, int year, int month, int day);

    // 해금여부 판단하는 api
    Boolean existsUserCLimbGroundByUserIdAndClimbGroundId(Long userId, Long climbGroundId);

    // 클라이밍장 기록 통계 조회(년별)
    @Query("SELECT uc FROM UserClimbGround uc " +
            "LEFT JOIN FETCH uc.user " +
            "LEFT JOIN FETCH uc.climbGround " +
            "LEFT JOIN FETCH uc.userDateList ud " +
            "LEFT JOIN FETCH ud.recordList r " +
            "LEFT JOIN FETCH r.hold h " +
            "WHERE uc.user.id = :userId " +
            "AND uc.climbGround.Id = :climbGroundId " +
            "AND FUNCTION('YEAR', ud.createdAt) = :year ")
    List<UserClimbGround> findClimbRecordsByUserIdAndClimbGroundIdAndYear(Long userId,Long climbGroundId, int year);

    // 클라이밍장 기록 통계 조회(년별)
    @Query("SELECT uc FROM UserClimbGround uc " +
            "LEFT JOIN FETCH uc.user " +
            "LEFT JOIN FETCH uc.climbGround " +
            "LEFT JOIN FETCH uc.userDateList ud " +
            "LEFT JOIN FETCH ud.recordList r " +
            "LEFT JOIN FETCH r.hold h " +
            "WHERE uc.user.id = :userId " +
            "AND uc.climbGround.Id = :climbGroundId " +
            "AND YEAR(ud.createdAt) = :year " +
            "AND WEEK(ud.createdAt) = :week")
    List<UserClimbGround> findClimbRecordsByUserIdAndClimbGroundIdAndMonth(Long userId,Long climbGroundId, int year, int month);

    // 클라이밍장 기록 통계 조회(년별)
    @Query("SELECT uc FROM UserClimbGround uc " +
            "LEFT JOIN FETCH uc.user " +
            "LEFT JOIN FETCH uc.climbGround " +
            "LEFT JOIN FETCH uc.userDateList ud " +
            "LEFT JOIN FETCH ud.recordList r " +
            "LEFT JOIN FETCH r.hold h " +
            "WHERE uc.user.id = :userId " +
            "AND uc.climbGround.Id = :climbGroundId " +
            "AND YEAR(ud.createdAt) = :year " +
            "AND MONTH(ud.createdAt) = :month " +
            "AND DAY(ud.createdAt) = :day")
    List<UserClimbGround> findClimbRecordsByUserIdAndClimbGroundIdAndDay(Long userId,Long climbGroundId, int year, int month, int day);
}

