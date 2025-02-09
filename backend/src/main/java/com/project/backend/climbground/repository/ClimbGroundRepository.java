package com.project.backend.climbground.repository;

import com.project.backend.climbground.dto.responseDTO.MiddleLockClimbGroundResponseDTO;
import com.project.backend.climbground.entity.ClimbGround;
import com.project.backend.userdate.dto.ClimbGroundWithDistance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

public interface ClimbGroundRepository extends JpaRepository<ClimbGround, Long> {

    Optional<ClimbGround> findClimbGroundWithHoldById(Long climbground_id);


//    c.address or c.name에 문자열이 포함되어 있는 record 찾기
    @Query("SELECT c from ClimbGround c " +
            "WHERE LOWER(c.address) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
            "OR LOWER(c.name) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<ClimbGround> searchClimbGround(@Param("keyword") String keyword);

    List<ClimbGround> findByIdIn(List<Long> climbgroundIds);

    @Query("SELECT new com.project.backend.climbground.dto.responseDTO.MiddleLockClimbGroundResponseDTO(" +
            "c.Id, c.name, c.image, c.address, c.latitude, c.longitude, " +
            "CASE WHEN uc.Id IS NOT NULL THEN false ELSE true END) " +
            "FROM ClimbGround c " +
            "LEFT JOIN UserClimbGround uc ON c.Id = uc.climbGround.Id AND uc.user.id = :userId")
    List<MiddleLockClimbGroundResponseDTO> findAllWithUnlockStatus(Long userId);


//    @Query(value = "SELECT * FROM ClimbGround ORDER BY ST_Distance_Sphere(point(longitude, latitude), point(:longitude, :latitude)) ASC LIMIT 1", nativeQuery = true)
//    ClimbGround findClimbGroundByDistance(BigDecimal latitude, BigDecimal longitude);

    // 도장깨기 페이지에서 특정 클라이밍장 해금 요청 하는 것
    @Query(value = "SELECT c.climbground_id AS climbGroundId, c.name AS name, " +
            "ST_Distance_Sphere(point(c.longitude, c.latitude), point(:longitude, :latitude)) AS distance " +
            "FROM climbground c " +
            "WHERE c.climbground_id = :climbGroundId ", nativeQuery = true)
    ClimbGroundWithDistance findClimbGroundByIDAndDistance(Long climbGroundId, BigDecimal latitude, BigDecimal longitude);


    // 카메라 촬영시 자동으로 해금
    @Query(value = "SELECT c.climbground_id AS climbGroundId, c.name AS name, " +
            "ST_Distance_Sphere(point(c.longitude, c.latitude), point(:longitude, :latitude)) AS distance " +
            "FROM ClimbGround c " +
            "ORDER BY distance ASC " +
            "LIMIT 1", nativeQuery = true)
    ClimbGroundWithDistance findClimbGroundByDistance(BigDecimal latitude, BigDecimal longitude);

    @Query("SELECT new com.project.backend.climbground.dto.responseDTO.MiddleLockClimbGroundResponseDTO(" +
            "c.Id, c.name, c.image, c.address, c.latitude, c.longitude, " +
            "CASE WHEN uc.Id IS NOT NULL THEN false ELSE true END) " +
            "FROM ClimbGround c " +
            "LEFT JOIN UserClimbGround uc ON c.Id = uc.climbGround.Id AND uc.user.id = :userId " +
            "WHERE LOWER(c.address) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
            "OR LOWER(c.name) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<ClimbGround> searchLockClimbGround(Long userId,String keyword);
}
