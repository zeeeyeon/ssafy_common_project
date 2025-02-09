package com.project.backend.climbground.controller;

import com.project.backend.climbground.dto.requsetDTO.ClimbGroundAllRequestDTO;
import com.project.backend.climbground.dto.requsetDTO.ClimbGroundSearchRequestDTO;
import com.project.backend.climbground.dto.requsetDTO.LockClimbGroundAllRequsetDTO;
import com.project.backend.climbground.dto.requsetDTO.MyClimbGroundRequestDTO;
import com.project.backend.climbground.dto.responseDTO.ClimbGroundAllResponseDTO;
import com.project.backend.climbground.dto.responseDTO.ClimbGroundDetailResponseDTO;
import com.project.backend.climbground.dto.responseDTO.LockClimbGroundAllResponseDTO;
import com.project.backend.climbground.dto.responseDTO.MyClimGroundResponseDTO;
import com.project.backend.climbground.service.ClimbGroundServiceImpl;
import com.project.backend.common.advice.exception.CustomException;
import com.project.backend.common.response.Response;
import com.project.backend.common.response.ResponseCode;
import com.project.backend.userclimbground.dto.responseDTO.UnLockClimbGroundDetailResponseDTO;
import com.project.backend.userclimbground.service.UserClimbGroundServiceImp;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

import static com.project.backend.common.response.ResponseCode.GET_CLIMB_GROUND_DETAIL;
import static com.project.backend.common.response.ResponseCode.GET_CLIMB_GROUND_List;


@RestController
@RequestMapping("/api/climbground")
@RequiredArgsConstructor
public class ClimbGroundController {


    private final ClimbGroundServiceImpl ClimbGroundService;
    private final UserClimbGroundServiceImp userClimbGroundServiceImp;

    // 클라이밍장 상세 조회
    @GetMapping("/detail/{climbground_id}")
    public ResponseEntity<?> getCLimbDetail(@PathVariable Long climbground_id) {
        Optional<ClimbGroundDetailResponseDTO> climbGroundDetail = ClimbGroundService.findClimbGroundDetailById(climbground_id);

        if(!climbGroundDetail.isEmpty()) {
            return new ResponseEntity<>(Response.create(GET_CLIMB_GROUND_DETAIL, climbGroundDetail), GET_CLIMB_GROUND_DETAIL.getHttpStatus());
        }
        throw new CustomException(ResponseCode.NOT_FOUND_CLIMB_GROUND);

    }

    // 클라이밍장 검색
    @GetMapping("/search")
    public ResponseEntity<?> searchClimbGround(@RequestParam("keyword") String keyword, @RequestParam(name = "latitude") double latitude, @RequestParam(name = "longitude") double longitude) {
        List<ClimbGroundAllResponseDTO> climbGrounds = ClimbGroundService.searchClimbGroundByKeyword(keyword,latitude,longitude);

        if (!climbGrounds.isEmpty()) {
            return new ResponseEntity<>(Response.create(GET_CLIMB_GROUND_List, climbGrounds), GET_CLIMB_GROUND_List.getHttpStatus());
        }

        throw new CustomException(ResponseCode.NO_MATCHING_CLIMBING_GYM);
    }
    // 클라이밍장 리스트 조회 (거리별 정렬)
    @GetMapping("/all/user-location")
    public ResponseEntity<?> getAllDisCLimbs(@RequestParam(name = "latitude") double latitude, @RequestParam(name = "longitude") double longitude) {
        List<ClimbGroundAllResponseDTO> climbGrounds = ClimbGroundService.findAllClimbGround(latitude,longitude);
        if (!climbGrounds.isEmpty()) {
            return new ResponseEntity<>(Response.create(GET_CLIMB_GROUND_List, climbGrounds), GET_CLIMB_GROUND_List.getHttpStatus());
        }
        throw new CustomException(ResponseCode.NOT_FOUND_CLIMB_GROUND);
    }

    @PostMapping("/my-climbground")
    public ResponseEntity<?> getMyClimbGround(@RequestBody MyClimbGroundRequestDTO requestDTO) {
        List<MyClimGroundResponseDTO> climbGrounds = ClimbGroundService.myClimbGroundWithIds(requestDTO);
        if (!climbGrounds.isEmpty()) {
            return new ResponseEntity<>(Response.create(GET_CLIMB_GROUND_List, climbGrounds), GET_CLIMB_GROUND_List.getHttpStatus());
        }
        throw new CustomException(ResponseCode.NOT_FOUND_CLIMB_GROUND);
    }

    @GetMapping("/lock-climbground/list")
    public ResponseEntity<?> getLockCimbGroundList(@RequestParam(name = "userId") Long userId, @RequestParam(name = "latitude") double latitude, @RequestParam(name = "longitude") double longitude) {
        List<LockClimbGroundAllResponseDTO> lockClimbGrounds = ClimbGroundService.findAllLockClimbGround(userId, latitude, longitude);

        if (!lockClimbGrounds.isEmpty()) {
            return  new ResponseEntity<>(Response.create(GET_CLIMB_GROUND_List, lockClimbGrounds), GET_CLIMB_GROUND_List.getHttpStatus());
        }
        throw new CustomException(ResponseCode.NOT_FOUND_CLIMB_GROUND);
    }

    @GetMapping("/lock-climbground/limit-five")
    public ResponseEntity<?> getLockCimbGroundLimitFive(@RequestParam(name = "userId") Long userId, @RequestParam(name = "latitude") double latitude, @RequestParam(name = "longitude") double longitude) {
        List<LockClimbGroundAllResponseDTO> lockClimbGrounds = ClimbGroundService.findAllLockClimbGroundLimitFive(userId, latitude, longitude);

        if (!lockClimbGrounds.isEmpty()) {
            return  new ResponseEntity<>(Response.create(GET_CLIMB_GROUND_List, lockClimbGrounds), GET_CLIMB_GROUND_List.getHttpStatus());
        }
        throw new CustomException(ResponseCode.NOT_FOUND_CLIMB_GROUND);
    }
    @GetMapping("/lock-climbground/detail")
    public ResponseEntity<?> getUnlockClimbGroundDetail(@RequestParam(name= "userId") Long userId, @RequestParam(name="climbGroundId") Long climbGroundId) {
        UnLockClimbGroundDetailResponseDTO responseDTO = userClimbGroundServiceImp.getUnlockClimbGroundDetail(userId, climbGroundId);

        return new ResponseEntity<>(Response.create(GET_CLIMB_GROUND_DETAIL, responseDTO), GET_CLIMB_GROUND_DETAIL.getHttpStatus());
    }

    @GetMapping("/lock-climbground/list/page")
    public ResponseEntity<?> getLockClimbGroundList(@RequestParam(name = "userId") Long userId, @RequestParam(name = "latitude") double latitude, @RequestParam(name = "longitude") double longitude, @RequestParam(name = "page") int page) {
        List<LockClimbGroundAllResponseDTO> lockClimbGrounds = ClimbGroundService.findAllLockClimbGroundPagination(userId, latitude, longitude,page);

        if (!lockClimbGrounds.isEmpty()) {
            return  new ResponseEntity<>(Response.create(GET_CLIMB_GROUND_List, lockClimbGrounds), GET_CLIMB_GROUND_List.getHttpStatus());
        }
        throw new CustomException(ResponseCode.NOT_FOUND_CLIMB_GROUND);
    }



}
