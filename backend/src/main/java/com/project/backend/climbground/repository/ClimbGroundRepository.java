package com.project.backend.climbground.repository;

import com.project.backend.climbground.entity.ClimbGround;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

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

}
