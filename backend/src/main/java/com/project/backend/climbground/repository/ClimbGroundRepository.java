package com.project.backend.climbground.repository;

import com.project.backend.climbground.entity.ClimbGround;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

public interface ClimbGroundRepository extends JpaRepository<ClimbGround, Long> {

    Optional<ClimbGround> findClimbGroundWithHoldById(Long climbground_id);


    // 거리순으로 정렬 탐색
    // HAVING distance < 10 일단 반경 내의 탐색 조건은 제거
    @Query("SELECT c FROM ClimbGround c WHERE " +
            "(6371 * acos(cos(radians(:latitude)) * cos(radians(c.latitude)) * " +
            "cos(radians(c.longitude) - radians(:longitude)) + " +
            "sin(radians(:latitude)) * sin(radians(c.latitude)))) " +
            "ORDER BY distance")
    List<ClimbGround> findAllClimbGroundWithDistance(
            @Param("latitude") BigDecimal latitude,
            @Param("longitude") BigDecimal longitude
    );

//    c.address or c.name에 문자열이 포함되어 있는 record 찾기
    @Query("SELECT c from ClimbGround c " +
            "WHERE LOWER(c.address) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
            "OR LOWER(c.name) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<ClimbGround> searchClimbGround(@Param("keyword") String keyword);

}
