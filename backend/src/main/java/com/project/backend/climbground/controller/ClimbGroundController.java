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
import com.project.backend.user.auth.CustomUserDetails;
import com.project.backend.userclimbground.dto.responseDTO.UnLockClimbGroundDetailResponseDTO;
import com.project.backend.userclimbground.service.UserClimbGroundServiceImp;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
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
    public ResponseEntity<?> getLockClimbGroundList(@AuthenticationPrincipal CustomUserDetails userDetails, @RequestParam(name = "latitude") double latitude, @RequestParam(name = "longitude") double longitude) {
        Long userId = userDetails.getUser().getId();
        List<LockClimbGroundAllResponseDTO> lockClimbGrounds = ClimbGroundService.findAllLockClimbGround(userId, latitude, longitude);

        if (!lockClimbGrounds.isEmpty()) {
            return  new ResponseEntity<>(Response.create(GET_CLIMB_GROUND_List, lockClimbGrounds), GET_CLIMB_GROUND_List.getHttpStatus());
        }
        throw new CustomException(ResponseCode.NOT_FOUND_CLIMB_GROUND);
    }

    @GetMapping("/lock-climbground/first")
    public ResponseEntity<?> getLockClimbGround(@AuthenticationPrincipal CustomUserDetails userDetails, @RequestParam(name = "latitude") double latitude, @RequestParam(name = "longitude") double longitude) {
        Long userId = userDetails.getUser().getId();
        LockClimbGroundAllResponseDTO lockClimbGround = ClimbGroundService.findAllLockClimbGroundFirst(userId, latitude, longitude);

        if (lockClimbGround != null) {
            return  new ResponseEntity<>(Response.create(GET_CLIMB_GROUND_List, lockClimbGround), GET_CLIMB_GROUND_List.getHttpStatus());
        }
        throw new CustomException(ResponseCode.NOT_FOUND_CLIMB_GROUND);
    }
    @GetMapping("/lock-climbground/detail")
    public ResponseEntity<?> getUnlockClimbGroundDetail(@AuthenticationPrincipal CustomUserDetails userDetails, @RequestParam(name="climbGroundId") Long climbGroundId) {
        Long userId = userDetails.getUser().getId();
        UnLockClimbGroundDetailResponseDTO responseDTO = userClimbGroundServiceImp.getUnlockClimbGroundDetail(userId, climbGroundId);

        return new ResponseEntity<>(Response.create(GET_CLIMB_GROUND_DETAIL, responseDTO), GET_CLIMB_GROUND_DETAIL.getHttpStatus());
    }

    // 클라이밍장 전체조회(해금 여부 포함) -paginateion
    @GetMapping("/lock-climbground/list/page")
    public ResponseEntity<?> getLockClimbGroundListPage(@AuthenticationPrincipal CustomUserDetails userDetails, @RequestParam(name = "latitude") double latitude, @RequestParam(name = "longitude") double longitude, @RequestParam(name = "page") int page) {
        Long userId = userDetails.getUser().getId();
        List<LockClimbGroundAllResponseDTO> lockClimbGrounds = ClimbGroundService.findAllLockClimbGroundPagination(userId, latitude, longitude,page);

        if (!lockClimbGrounds.isEmpty()) {
            return  new ResponseEntity<>(Response.create(GET_CLIMB_GROUND_List, lockClimbGrounds), GET_CLIMB_GROUND_List.getHttpStatus());
        }
        throw new CustomException(ResponseCode.NOT_FOUND_CLIMB_GROUND);
    }

    // 클라이밍장 리스트 조회 (거리별 정렬) - 페이지네이션
    @GetMapping("/all/user-location/page")
    public ResponseEntity<?> getAllDisCLimbsPage(@AuthenticationPrincipal CustomUserDetails userDetails,@RequestParam(name = "latitude") double latitude, @RequestParam(name = "longitude") double longitude ,@RequestParam(name="page") int page) {
        Long userId = userDetails.getUser().getId();
        List<ClimbGroundAllResponseDTO> climbGrounds = ClimbGroundService.findAllClimbGroundPagination(userId, latitude,longitude,page);
        if (!climbGrounds.isEmpty()) {
            return new ResponseEntity<>(Response.create(GET_CLIMB_GROUND_List, climbGrounds), GET_CLIMB_GROUND_List.getHttpStatus());
        }
        throw new CustomException(ResponseCode.NOT_FOUND_CLIMB_GROUND);
    }

    // 클라이밍장 검색
    @GetMapping("/lock-climbground/search")
    public ResponseEntity<?> searchLockClimbGround(@AuthenticationPrincipal CustomUserDetails userDetails ,@RequestParam(name = "keyword") String keyword, @RequestParam(name = "latitude") double latitude, @RequestParam(name = "longitude") double longitude) {
        Long userId = userDetails.getUser().getId();
        List<LockClimbGroundAllResponseDTO> climbGrounds = ClimbGroundService.searchLockClimbGroundByKeyword(userId,keyword,latitude,longitude);

        if (!climbGrounds.isEmpty()) {
            return new ResponseEntity<>(Response.create(GET_CLIMB_GROUND_List, climbGrounds), GET_CLIMB_GROUND_List.getHttpStatus());
        }

        throw new CustomException(ResponseCode.NO_MATCHING_CLIMBING_GYM);
    }

}
