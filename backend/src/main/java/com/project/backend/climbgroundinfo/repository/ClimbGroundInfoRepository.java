package com.project.backend.climbgroundinfo.repository;

import com.project.backend.climbgroundinfo.entity.ClimbGroundInfo;
import com.project.backend.info.entity.Info;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ClimbGroundInfoRepository extends CrudRepository<ClimbGroundInfo, Long> {

    @Query("SELECT ci.info FROM ClimbGroundInfo ci WHERE ci.climbGround.id = :climbgroundId")
    List<Info> findInfosByClimbGroundId(@Param("climbgroundId") Long climbgroundId);
}
