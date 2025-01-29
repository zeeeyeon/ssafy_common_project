package com.project.backend.climbground.repository;

import com.project.backend.climbground.entity.ClimbGround;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface ClimbGroundRepository extends JpaRepository<ClimbGround, Long> {

    Optional<ClimbGround> findClimbGroundWithHoldById(Long climbground_id);

//    @Query("SELECT c from ClimbGround c " +
//            "left join fetch c.holdList " +
//            "where c.id = :climbground_id")
//    Optional<ClimbGround> findClimbGroundWithHoldById(@Param("climbground_id") Long climbground_id);

}
