package com.project.backend.user.controller;

import com.project.backend.common.advice.exception.CustomException;
import com.project.backend.common.response.Response;
import com.project.backend.common.response.ResponseCode;
import com.project.backend.user.auth.CustomUserDetails;
import com.project.backend.user.dto.UserTierRequestDto;
import com.project.backend.user.dto.request.ConvertRequestDto;
import com.project.backend.user.dto.request.SignUpRequestDto;
import com.project.backend.user.dto.request.UserImageRequestDto;
import com.project.backend.user.dto.request.UserInfoRequestDto;
import com.project.backend.user.dto.response.*;
import com.project.backend.user.entity.User;
import com.project.backend.user.service.UserService;
import com.project.backend.userclimbground.entity.UserClimbGroundMedalEnum;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Optional;

import static com.project.backend.common.response.ResponseCode.*;
import static com.project.backend.common.response.ResponseCode.SUCCESS_CONVERT;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserController {

  private final UserService userService;

  // 일반 사용자 회원가입
  @PostMapping("/signup")
  public ResponseEntity<?> signUp(@RequestBody @Valid SignUpRequestDto signUpRequestDto) {
    userService.signUp(signUpRequestDto);
    return new ResponseEntity<>(Response.create(SUCCESS_SIGNUP, null), SUCCESS_SIGNUP.getHttpStatus());
  }

  // 소셜 사용자 전환
  @PostMapping("/social-update")
  public ResponseEntity<?> updateSocialUser(@AuthenticationPrincipal CustomUserDetails userDetails, @RequestBody ConvertRequestDto convertRequestDto) {
    User user = userService.updateSocialUser(userDetails.getUser(), convertRequestDto);
    ConvertResponseDto responseDto = new ConvertResponseDto(user);
    return new ResponseEntity<>(Response.create(SUCCESS_CONVERT, responseDto), SUCCESS_CONVERT.getHttpStatus());
  }

  // 이메일 중복 체크
  @GetMapping("/email-check")
  public ResponseEntity<?> emailDuplicationCheck(@RequestParam(name = "email") String email) {
    Optional<User> user = userService.checkEmailDuplication(email);
    if(user.isPresent()) {
      throw new CustomException(EXISTED_USER_EMAIL);
    }
    return new ResponseEntity<>(Response.create(NO_EXISTED_USER_EMAIL, null), NO_EXISTED_USER_EMAIL.getHttpStatus());
  }

  // 닉네임 중복 체크
  @GetMapping("/nickname-check")
  public ResponseEntity<?> nicknameDuplicationCheck(@RequestParam(name = "nickname") String nickname) {
    Optional<User> user = userService.checkNicknameDuplication(nickname);
    if(user.isPresent()) {
      throw new CustomException(EXISTED_USER_NICKNAME);
    }
    return new ResponseEntity<>(Response.create(NO_EXISTED_USER_NICKNAME, null), NO_EXISTED_USER_NICKNAME.getHttpStatus());
  }

  // 사용자 프로필 조회 ( 닉네임, 클라이밍 시작일, 키, 팔길이)
  @GetMapping("/profile")
  public ResponseEntity<?> findUserProfile(@AuthenticationPrincipal CustomUserDetails userDetails) {
    Long userId = userDetails.getUser().getId();
    User user = userService.userProfileFindById(userId);
    UserProfileResponseDto responseDto = new UserProfileResponseDto(user);
    return new ResponseEntity<>(Response.create(ResponseCode.GET_USER_PROFILE, responseDto), GET_USER_PROFILE.getHttpStatus());
  }

  // 사용자 프로필 수정 ( 닉네임, 클라이밍 시작일, 키, 팔길이)
  @PutMapping("/profile")
  public ResponseEntity<?> updateUserProfile(@AuthenticationPrincipal CustomUserDetails userDetails, @RequestBody UserInfoRequestDto requestDto) {
    Long userId = userDetails.getUser().getId();
    userService.updateUserProfileById(userId, requestDto);
    return new ResponseEntity<>(Response.create(ResponseCode.UPDATE_USER_PROFILE, null), UPDATE_USER_PROFILE.getHttpStatus());
  }

  @PutMapping("/image")
  public ResponseEntity<?> updateUserImage(@AuthenticationPrincipal CustomUserDetails userDetails, @RequestPart("file")MultipartFile image) {
    Long userId = userDetails.getUser().getId();
    userService.updateUserImageById(userId, image);
    return new ResponseEntity<>(Response.create(ResponseCode.UPDATE_USER_PROFILE, null), UPDATE_USER_PROFILE.getHttpStatus());
  }

  // 사용자 티어 조회
  @GetMapping("/tier")
  public ResponseEntity<?> findUserTier(@AuthenticationPrincipal CustomUserDetails userDetails) {
    Long userId = userDetails.getUser().getId();
    UserTierResponseDto responseDto = userService.userTierFindById(userId);
    return new ResponseEntity<>(Response.create(ResponseCode.GET_USER_TIER, responseDto), GET_USER_TIER.getHttpStatus());
  }

  // 사용자 티어 갱신
  @PatchMapping("/tier")
  public ResponseEntity<?> updateUserTier(@AuthenticationPrincipal CustomUserDetails userDetails) {
    Long userId = userDetails.getUser().getId();
    User findUser = userService.updateUserTier(userId);
    UserTierResponseDto responseDto = new UserTierResponseDto(findUser);
    return new ResponseEntity<>(Response.create(ResponseCode.UPDATE_USER_TIER, responseDto), UPDATE_USER_TIER.getHttpStatus());
  }

  // 클라이밍장별 메달 조회
  @GetMapping("/climbground/medal/{climbId}")
  public ResponseEntity<?> findMedalPerClimbGround(@AuthenticationPrincipal CustomUserDetails userDetails, @PathVariable(name = "climbId") Long climbId) {
    Long userId = userDetails.getUser().getId();
    UserClimbGroundMedalEnum medal = userService.findMedalPerClimbGround(userId, climbId);
    UserMedalPerClimbGroundResponseDto responseDto = new UserMedalPerClimbGroundResponseDto(medal);
    return new ResponseEntity<>(Response.create(ResponseCode.GET_USER_CLIMB_GROUND_MEDAL, responseDto), GET_USER_CLIMB_GROUND_MEDAL.getHttpStatus());
  }


  // 클라이밍장별 매달 갱신
  @PatchMapping("/climbground/medal/{climbId}")
  public ResponseEntity<?> updateMedalPerClimbGround(@AuthenticationPrincipal CustomUserDetails userDetails, @PathVariable(name = "climbId") Long climbId) {
    Long userId = userDetails.getUser().getId();
    UserClimbGroundMedalEnum medal = userService.updateMedalPerClimbGround(userId, climbId);
    UserMedalPerClimbGroundResponseDto responseDto = new UserMedalPerClimbGroundResponseDto(medal);
    return new ResponseEntity<>(Response.create(ResponseCode.GET_USER_CLIMB_GROUND_MEDAL, responseDto), GET_USER_CLIMB_GROUND_MEDAL.getHttpStatus());
  }
}
