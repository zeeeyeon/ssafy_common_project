package com.project.backend.climbground.service;

import com.project.backend.climbground.dto.responseDTO.ClimbGroundAllResponseDTO;
import com.project.backend.climbground.dto.responseDTO.ClimbGroundDetailResponseDTO;
import com.project.backend.climbground.entity.ClimbGround;
import com.project.backend.climbground.repository.ClimbGroundRepository;
import com.project.backend.climbgroundinfo.repository.ClimbGroundInfoRepository;
import com.project.backend.hold.dto.responseDTO.HoldResponseDTO;
import com.project.backend.info.dto.responseDTO.InfoResponseDTO;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class ClimbGroundServiceImpl implements ClimbGroundService {

    @Autowired
    private ClimbGroundRepository climbGroundRepository;

    @Autowired
    private ClimbGroundInfoRepository climbGroundInfoRepository;

    // 클라이밍장 전체 조회
    @Override
    public List<ClimbGroundAllResponseDTO> findAllClimbGround(BigDecimal latitude, BigDecimal longitude) {
        List<ClimbGround> climbGrounds = climbGroundRepository.findAll();
        List<ClimbGroundAllResponseDTO> responseList = climbGrounds.stream().map(climb -> new ClimbGroundAllResponseDTO(climb.getId(), climb.getName(), climb.getImage(), climb.getAddress()))
                .collect(Collectors.toList());


        return responseList;
    }

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

    @Override
    public List<ClimbGroundAllResponseDTO> searchClimbGroundByKeyword(String keyword) {
        //검색결과가 나올수도 안나올수도 여러 개일수도 한개 일수도 있음
        List<ClimbGround> climbGrounds = climbGroundRepository.searchClimbGround(keyword);

        // 검색 결과 없으면 빈리스트 주기
        if (climbGrounds.isEmpty()) {
            return List.of();
        }

        List<ClimbGroundAllResponseDTO> resultList = climbGrounds.stream()
                .map(climbGround -> new ClimbGroundAllResponseDTO(climbGround.getId(),climbGround.getName(),climbGround.getImage(),climbGround.getAddress()))
                .collect(Collectors.toList());

        return resultList;




    }


}
