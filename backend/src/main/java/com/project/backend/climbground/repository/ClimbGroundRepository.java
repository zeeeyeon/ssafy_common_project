package com.project.backend.climbground.repository;

import com.project.backend.climbground.entity.ClimbGround;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ClimbGroundRepository extends JpaRepository<ClimbGround, Long> {

//    @Query("SELECT c from ClimbGround c " +
//            "left join fetch c.holdList " + // 필요하다면 홀드도 함께 가져옵니다
//            "left join fetch c.climbGroundInfoList ci " +
//            "left join fetch ci.info " +
//            "where c.id = :climbground_id")
//    ClimbGround findClimbWithInfosById(@Param("climbground_id") Long climbground_id);
}
