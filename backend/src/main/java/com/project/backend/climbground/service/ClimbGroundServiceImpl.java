package com.project.backend.climbground.service;

import com.project.backend.climbground.dto.requsetDTO.ClimbGroundAllRequestDTO;
import com.project.backend.climbground.dto.requsetDTO.ClimbGroundSearchRequestDTO;
import com.project.backend.climbground.dto.requsetDTO.LockClimbGroundAllRequsetDTO;
import com.project.backend.climbground.dto.requsetDTO.MyClimbGroundRequestDTO;
import com.project.backend.climbground.dto.responseDTO.*;
import com.project.backend.climbground.entity.ClimbGround;
import com.project.backend.climbground.repository.ClimbGroundRepository;
import com.project.backend.climbgroundinfo.repository.ClimbGroundInfoRepository;
import com.project.backend.hold.dto.responseDTO.HoldResponseDTO;
import com.project.backend.info.dto.responseDTO.InfoResponseDTO;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ClimbGroundServiceImpl implements ClimbGroundService {

    private final ClimbGroundRepository climbGroundRepository;

    private final ClimbGroundInfoRepository climbGroundInfoRepository;

    //클라이밍장 상세 페이지
    @Override
    @Transactional
    public Optional<ClimbGroundDetailResponseDTO> findClimbGroundDetailById(Long climbground_id) {
        ClimbGround climbGround = climbGroundRepository.findClimbGroundWithHoldById(climbground_id)
                .orElseThrow(() -> new EntityNotFoundException());

        // 클라이밍장 hold 정보 가져오기
        List<HoldResponseDTO> holds = climbGround.getHoldList().stream()
                .map(hold -> new HoldResponseDTO(hold.getId(),hold.getLevel(),hold.getColor()))
                .sorted(Comparator.comparing(HoldResponseDTO::getLevel))
                .collect(Collectors.toList());

        // 클라이밍장의 시설정보 가져오기
        List<InfoResponseDTO> infos = climbGroundInfoRepository.findInfosByClimbGroundId(climbground_id)
                .stream()
                .map(info -> new InfoResponseDTO(info.getInfo()))
                .collect(Collectors.toList());

        ClimbGroundDetailResponseDTO response = new ClimbGroundDetailResponseDTO();

        response.setId(climbGround.getId());
        response.setName(climbGround.getName());
        response.setAddress(climbGround.getAddress());
        response.setImage(climbGround.getImage());
        response.setLatitude(climbGround.getLatitude());
        response.setLongitude(climbGround.getLongitude());
        response.setNumber(String.valueOf(climbGround.getNumber()));
        response.setOpen(climbGround.getOpen());
        response.setSns_url(climbGround.getSns_url());
        response.setHolds(holds);
        response.setInfos(infos);

        return Optional.of(response);
    }

//    @Override
//    public List<ClimbGroundAllResponseDTO> searchClimbGroundByKeyword(ClimbGroundSearchRequestDTO requestDTO) {
//        //검색결과가 나올수도 안나올수도 여러 개일수도 한개 일수도 있음
//        List<ClimbGround> climbGrounds = climbGroundRepository.searchClimbGround(requestDTO.getKeyword());
//
//        // 검색 결과 없으면 빈리스트 주기
//        if (climbGrounds.isEmpty()) {
//            return List.of();
//        }
//        List<ClimbGroundAllResponseDTO> responseList = climbGrounds.stream().map(climb -> {
//
//            double distance = calculateDistance(requestDTO.getLatitude(),requestDTO.getLongitude(),climb.getLatitude(),climb.getLongitude());
//
//            return new ClimbGroundAllResponseDTO(
//                    climb.getId(),
//                    climb.getName(),
//                    climb.getImage(),
//                    climb.getAddress(),
//                    distance
//            );
//        }).sorted(Comparator.comparing(ClimbGroundAllResponseDTO::getDistance)).collect(Collectors.toList());
//
//
//        return responseList;
//
//    }

    // 클라이밍장 전체 조회 (거리별 정렬)
    @Override
    public List<ClimbGroundAllResponseDTO> findAllClimbGround(ClimbGroundAllRequestDTO requestDTO) {
        List<ClimbGround> climbGrounds = climbGroundRepository.findAll();
        List<ClimbGroundAllResponseDTO> responseList = climbGrounds.stream().map(climb -> {

            double distance = calculateDistance(requestDTO.getLatitude(),requestDTO.getLongitude(),climb.getLatitude(),climb.getLongitude());

            return new ClimbGroundAllResponseDTO(
                    climb.getId(),
                    climb.getName(),
                    climb.getImage(),
                    climb.getAddress(),
                    distance
            );
        }).sorted(Comparator.comparing(ClimbGroundAllResponseDTO::getDistance)).collect(Collectors.toList());

        return responseList;
    }

    @Override
    public List<MyClimGroundResponseDTO> myClimbGroundWithIds(MyClimbGroundRequestDTO requestDTO){
        List<ClimbGround> climbGrounds = climbGroundRepository.findByIdIn(requestDTO.getClimbGroundIds());

        List<MyClimGroundResponseDTO> responseList = climbGrounds.stream().map(climbGround -> {

            return new MyClimGroundResponseDTO(
                    climbGround.getId(),
                    climbGround.getName(),
                    climbGround.getImage(),
                    climbGround.getAddress()
            );
        }).collect(Collectors.toList());
        return responseList;
    }

    // 클라이밍장별 거리 계산
    public double calculateDistance(BigDecimal lat1, BigDecimal lon1, BigDecimal lat2, BigDecimal lon2){
        final int EARTH_RADIUS = 6371; // 지구 반지름 (km)

        double latDistance = Math.toRadians(lat2.doubleValue() - lat1.doubleValue());
        double lonDistance = Math.toRadians(lon2.doubleValue() - lon1.doubleValue());

        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1.doubleValue())) * Math.cos(Math.toRadians(lat2.doubleValue()))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double distance = EARTH_RADIUS * c; // 거리(km)

        return Math.round(distance * 100.0) / 100.0; // 소수점 둘째 자리까지 반올림
    };

    @Override
    public List<LockClimbGroundAllResponseDTO> findAllLockClimbGround(LockClimbGroundAllRequsetDTO requestDTO) {
          List<MiddleLockClimbGroundResponseDTO> middleLockClimbGrounds = climbGroundRepository.findAllWithUnlockStatus(requestDTO.getUserId());

          List<LockClimbGroundAllResponseDTO> responseList = middleLockClimbGrounds.stream().map(
                  middleLockClimbGround -> {
                      double distance = calculateDistance(requestDTO.getLatitude(),requestDTO.getLongitude(), middleLockClimbGround.getLatitude(),middleLockClimbGround.getLongitude());

                      return new LockClimbGroundAllResponseDTO(
                              middleLockClimbGround.getClimbGroundId(),
                              middleLockClimbGround.getName(),
                              middleLockClimbGround.getImage(),
                              middleLockClimbGround.getAddress(),
                              distance,
                              middleLockClimbGround.isLocked()
                              );
                  }).sorted(Comparator.comparing(LockClimbGroundAllResponseDTO::getDistance)).collect(Collectors.toList());
          return responseList;

    };

    @Override
    public List<LockClimbGroundAllResponseDTO> findAllLockClimbGroundLimitFive(LockClimbGroundAllRequsetDTO requestDTO) {
        List<MiddleLockClimbGroundResponseDTO> middleLockClimbGrounds = climbGroundRepository.findAllWithUnlockStatus(requestDTO.getUserId());

        List<LockClimbGroundAllResponseDTO> responseList = middleLockClimbGrounds.stream().map(
                middleLockClimbGround -> {
                    double distance = calculateDistance(requestDTO.getLatitude(), requestDTO.getLongitude(), middleLockClimbGround.getLatitude(), middleLockClimbGround.getLongitude());

                    return new LockClimbGroundAllResponseDTO(
                            middleLockClimbGround.getClimbGroundId(),
                            middleLockClimbGround.getName(),
                            middleLockClimbGround.getImage(),
                            middleLockClimbGround.getAddress(),
                            distance,
                            middleLockClimbGround.isLocked()
                    );
                }).sorted(Comparator.comparing(LockClimbGroundAllResponseDTO::getDistance)).limit(5).collect(Collectors.toList());
        return responseList;
    };
}
