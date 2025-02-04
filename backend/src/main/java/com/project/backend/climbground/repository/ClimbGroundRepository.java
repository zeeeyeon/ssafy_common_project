package com.project.backend.climbground.repository;

import com.project.backend.climbground.dto.responseDTO.MiddleLockClimbGroundResponseDTO;
import com.project.backend.climbground.entity.ClimbGround;
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
            "CASE WHEN uc.Id IS NOT NULL THEN true ELSE false END) " +
            "FROM ClimbGround c " +
            "LEFT JOIN UserClimbGround uc ON c.Id = uc.climbGround.Id AND uc.user.id = :userId")
    List<MiddleLockClimbGroundResponseDTO> findAllWithUnlockStatus(Long userId);
}
