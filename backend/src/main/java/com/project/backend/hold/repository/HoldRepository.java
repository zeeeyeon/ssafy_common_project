package com.project.backend.hold.repository;

import com.project.backend.hold.dto.HoldColorLevelDto;
import com.project.backend.hold.entity.Hold;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface HoldRepository extends JpaRepository<Hold, Long> {

    @Query("SELECT new com.project.backend.hold.dto.HoldColorLevelDto(h.color, h.level) " +
            "FROM Hold h " +
            "WHERE h.climbGround.Id = :climbGroundId")
    List<HoldColorLevelDto> findHoldColorLevelByClimbGroundId(Long climbGroundId);
}
