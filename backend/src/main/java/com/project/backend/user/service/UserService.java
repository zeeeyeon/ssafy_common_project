package com.project.backend.user.service;

import com.project.backend.user.dto.UserTierRequestDto;
import com.project.backend.user.dto.request.ConvertRequestDto;
import com.project.backend.user.dto.request.SignUpRequestDto;
import com.project.backend.user.dto.request.UserImageRequestDto;
import com.project.backend.user.dto.request.UserInfoRequestDto;
import com.project.backend.user.dto.response.UserTierResponseDto;
import com.project.backend.user.entity.User;
import com.project.backend.userclimbground.entity.UserClimbGroundMedalEnum;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.Optional;

@Service
public interface UserService {
  public User getUserByUserName(String userName);
  public void signUp(SignUpRequestDto signUpRequestDto);
  public User updateSocialUser(User user, ConvertRequestDto convertRequestDto);
  public Optional<User> checkEmailDuplication(String email);
  public Optional<User> checkNicknameDuplication(String nickname);
  // 사용자 ID로 사용자 프로필 조회
  public User userProfileFindById(Long id);
  // 사용자 ID로 사용자 프로필 갱신
  public void updateUserProfileById(Long id, UserInfoRequestDto requestDto);
  // 사용자 ID로 사용자 이미지 갱신
  public void updateUserImageById(Long id, MultipartFile image);
  // 사용자 ID로 티어 조회
  public UserTierResponseDto userTierFindById(Long id);
  // 사용자 티어 갱신
  public User updateUserTier(Long id);
  // 클라이밍장별 메달 조회
  public UserClimbGroundMedalEnum findMedalPerClimbGround(Long userId, Long climbId);
  // 클라이밍장별 메달 갱신
  public UserClimbGroundMedalEnum updateMedalPerClimbGround(Long userId, Long climbId);
}
