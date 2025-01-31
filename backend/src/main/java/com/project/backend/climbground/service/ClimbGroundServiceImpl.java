package com.project.backend.climbground.service;

import com.project.backend.climbground.entity.ClimbGround;
import com.project.backend.climbground.repository.ClimbGroundRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ClimbGroundServiceImpl implements ClimbGroundService {

    @Autowired
    private ClimbGroundRepository climbGroundRepository;

    // 클라이밍장 전체 조회
    @Override
    public List<ClimbGround> findAllClimbGround() {
        return climbGroundRepository.findAll();
    }

    // 클라이밍장 상세 조회


    // 클라이밍 장별 시설정보 조회 메서드
//    public ClimbGround getClimbWithInfos(Long climb_id) {
//        return  climbGroundRepository.findClimbWithInfosById(climb_id);
//    }

    @Override
    public Optional<ClimbGround> findClimbGroundById(Long id) {
        return climbGroundRepository.findById(id);
    }

}
