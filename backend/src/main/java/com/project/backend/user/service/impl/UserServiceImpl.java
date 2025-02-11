package com.project.backend.user.service.impl;

import com.project.backend.climbground.entity.ClimbGround;
import com.project.backend.climbground.repository.ClimbGroundRepository;
import com.project.backend.common.advice.exception.CustomException;
import com.project.backend.common.response.ResponseCode;
import com.project.backend.record.entity.ClimbingRecord;
import com.project.backend.user.dto.request.ConvertRequestDto;
import com.project.backend.user.dto.request.SignUpRequestDto;
import com.project.backend.user.dto.request.UserImageRequestDto;
import com.project.backend.user.dto.request.UserInfoRequestDto;
import com.project.backend.user.dto.response.UserTierResponseDto;
import com.project.backend.user.entity.User;
import com.project.backend.user.entity.UserTierEnum;
import com.project.backend.user.repository.jpa.UserRepository;
import com.project.backend.user.service.UserService;
import com.project.backend.userclimbground.entity.UserClimbGround;
import com.project.backend.userclimbground.entity.UserClimbGroundMedalEnum;
import com.project.backend.userclimbground.repository.UserClimbGroundRepository;
import com.project.backend.video.service.S3UploadService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.Optional;

@RequiredArgsConstructor
@Transactional
@Service
public class UserServiceImpl implements UserService {

  private final UserRepository userRepository;
  private final ClimbGroundRepository climbGroundRepository;
  private final UserClimbGroundRepository userClimbGroundRepository;
  private final S3UploadService s3UploadService;
  private final BCryptPasswordEncoder passwordEncoder;

  public User getUserByUserName(String userName){
    return userRepository.findByUsername(userName).orElseThrow();
  }

  @Override
  public void signUp(SignUpRequestDto signUpRequestDto) {
    // 1) 해당 사용자의 입력 이메일이 이미 존재하는 계정인지 확인
    Optional<User> existedUser = userRepository.findByEmail(signUpRequestDto.getEmail());
    if(existedUser.isPresent()) {
      throw new CustomException(ResponseCode.EXISTED_USER_EMAIL);
    }
    // 2) 해당 사용자의 입력 연락처가 이미 존재하는 계정인지 확인
    Optional<User> existedUserPhone = userRepository.findByPhone(signUpRequestDto.getPhone());
    if(existedUserPhone.isPresent()) {
      throw new CustomException(ResponseCode.EXISTED_USER_PHONE);
    }
    // 3) 해당 사용자의 입력 닉네임이 이미 존재하는 계정인지 확인
    Optional<User> existedUserNickname = userRepository.findByNickname(signUpRequestDto.getNickname());
    if(existedUserNickname.isPresent()) {
      throw new CustomException(ResponseCode.EXISTED_USER_NICKNAME);
    }

    // 1, 2, 3 해당 사항이 없다면 정상적으로 회원가입 진행
    userRepository.save(signUpRequestDto.toUserEntity(passwordEncoder));

  }

  public User updateSocialUser(User user, ConvertRequestDto convertRequestDto) {
    User findUser = userRepository.findById(user.getId())
            .orElseThrow(() -> new CustomException(ResponseCode.NOT_FOUND_USER));

    // 전화번호 중복 체크
    Optional<User> existedUserPhone = userRepository.findByPhone(convertRequestDto.getPhone());
    if(existedUserPhone.isPresent()) {
      throw new CustomException(ResponseCode.EXISTED_USER_PHONE);
    }

    // 닉네임 중복 체크
    Optional<User> existedUserNickname = userRepository.findByNickname(convertRequestDto.getNickname());
    if(existedUserNickname.isPresent()) {
      throw new CustomException(ResponseCode.EXISTED_USER_NICKNAME);
    }

    // 기존 사용자 정보 업데이트
    findUser.setPassword(passwordEncoder.encode(convertRequestDto.getPassword()));
    findUser.setUsername(convertRequestDto.getUsername());
    findUser.setPhone(convertRequestDto.getPhone());
    findUser.setNickname(convertRequestDto.getNickname());
    findUser.setUpdateDate(LocalDateTime.now());

    return userRepository.save(findUser);
  }

  @Override
  public Optional<User> checkEmailDuplication(String email) {
    return userRepository.findByEmail(email);
  }

  @Override
  public Optional<User> checkNicknameDuplication(String nickname) {
    return userRepository.findByNickname(nickname);
  }

  @Override
  public User userProfileFindById(Long id) {
    return userRepository.findById(id).orElseThrow(() -> new CustomException(ResponseCode.NOT_FOUND_USER));
  }

  @Override
  public void updateUserProfileById(Long id, UserInfoRequestDto requestDto) {
    User findUser = userRepository.findById(id).orElseThrow(() -> new CustomException(ResponseCode.NOT_FOUND_USER));
    userRepository.save(findUser.setUserInfoRequestDto(requestDto));
  }

  @Override
  public void updateUserImageById(Long id, MultipartFile image) {
    User findUser = userRepository.findById(id)
            .orElseThrow(() -> new CustomException(ResponseCode.NOT_FOUND_USER));

    // 파일 검증: 이미지 파일 타입과 사이즈 체크
    s3UploadService.checkImageFileTypeOrThrow(image);
    s3UploadService.checkImageFileSizeOrThrow(image);

    // 고유 파일명 생성 (타임스탬프와 원래 파일명 조합)
    String originalFilename = image.getOriginalFilename();
    String fileBaseName = org.apache.commons.io.FilenameUtils.getBaseName(originalFilename);
    String fileExtension = org.apache.commons.io.FilenameUtils.getExtension(originalFilename);
    String imageName = "profile_" + System.currentTimeMillis() + "_" + fileBaseName + "." + fileExtension;

    try {
      // S3에 파일 업로드 후, 업로드된 이미지 URL 획득
      String imageUrl = s3UploadService.saveImage(image, imageName);

      // User 엔티티의 프로필 이미지 URL 필드를 업데이트
      findUser.setProfileImageUrl(imageUrl);
      userRepository.save(findUser);
    } catch (IOException e) {
      // 업로드 실패시 커스텀 예외 발생 (ResponseCode는 필요에 따라 추가)
      throw new CustomException(ResponseCode.IMAGE_UPLOAD_FAILED);
    }
  }

  public UserTierResponseDto userTierFindById(Long id) {
    User user = userRepository.findById(id).orElseThrow();
    return new UserTierResponseDto(user);
  }

  public User updateUserTier(Long id) {
    User findUser = userRepository.findById(id)
            .orElseThrow(() -> new CustomException(ResponseCode.NOT_FOUND_USER));

    int totalScore = findUser.getUserClimbGroundList().stream()
            .map(UserClimbGround::getMedal)
            .mapToInt(UserClimbGroundMedalEnum::getScore)
            .sum();

    UserTierEnum newTier = UserTierEnum.getTierByScore(totalScore);
    findUser.setTier(newTier);

    return userRepository.save(findUser);
  }

  public UserClimbGroundMedalEnum findMedalPerClimbGround(Long userId, Long climbId) {
    User findUser = userRepository.findById(userId).orElseThrow(() -> new CustomException(ResponseCode.NOT_FOUND_USER));
    ClimbGround findClimbGround = climbGroundRepository.findById(climbId).orElseThrow(() -> new CustomException(ResponseCode.NOT_FOUND_CLIMBGOUND));

    UserClimbGround userClimbGround = userClimbGroundRepository.findByUserAndClimbGround(findUser, findClimbGround)
            .orElseThrow(() -> new CustomException(ResponseCode.NOT_FOUND_USER_CLIMBGROUND));

    return userClimbGround.getMedal();
  }

  @Override
  public UserClimbGroundMedalEnum updateMedalPerClimbGround(Long userId, Long climbId) {
    User findUser = userRepository.findById(userId)
            .orElseThrow(() -> new CustomException(ResponseCode.NOT_FOUND_USER));
    ClimbGround findClimbGround = climbGroundRepository.findById(climbId)
            .orElseThrow(() -> new CustomException(ResponseCode.NOT_FOUND_CLIMBGOUND));

    UserClimbGround userClimbGround = userClimbGroundRepository
            .findByUserAndClimbGround(findUser, findClimbGround)
            .orElse(UserClimbGround.builder()
                    .user(findUser)
                    .climbGround(findClimbGround)
                    .medal(UserClimbGroundMedalEnum.BRONZE)  // 동메달로 초기화
                    .build());

    // 시도 횟수 계산
    long totalAttempts = userClimbGround.getUserDateList().stream()
            .flatMap(userDate -> userDate.getClimbingRecordList().stream())
            .count();

    // 성공 횟수 계산
    long successfulAttempts = userClimbGround.getUserDateList().stream()
            .flatMap(userDate -> userDate.getClimbingRecordList().stream())
            .filter(ClimbingRecord::isSuccess)
            .count();

    // 메달 업데이트 로직
    UserClimbGroundMedalEnum newMedal = UserClimbGroundMedalEnum.BRONZE;

    if (totalAttempts >= 5) {
      if (totalAttempts > 0 && (double) successfulAttempts / totalAttempts >= 0.5) {
        newMedal = UserClimbGroundMedalEnum.GOLD;
      } else {
        newMedal = UserClimbGroundMedalEnum.SILVER;
      }
    }

    // 메달 업데이트 및 저장
    if (userClimbGround.getId() == null || !userClimbGround.getMedal().equals(newMedal)) {
      userClimbGround.updateMedal(newMedal);
      userClimbGroundRepository.save(userClimbGround);
    }

    return userClimbGround.getMedal();
  }
}
