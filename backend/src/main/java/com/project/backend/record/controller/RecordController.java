package com.project.backend.record.controller;

import com.project.backend.common.advice.exception.CustomException;
import com.project.backend.common.response.Response;
import com.project.backend.common.response.ResponseCode;
import com.project.backend.record.dto.requestDTO.RecordSaveRequestDTO;
import com.project.backend.record.entity.ClimbingRecord;
import com.project.backend.record.service.ClimbingRecordService;
import com.project.backend.record.service.ClimbingRecordServiceImpl;
import com.project.backend.record.service.VideoUploadService;
import com.project.backend.user.auth.CustomUserDetails;
import com.project.backend.video.dto.responseDTO.VideoSaveResponseDTO;
import com.project.backend.video.service.S3UploadService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Optional;

import static com.project.backend.common.response.ResponseCode.SUCCESS_FILE_UPLOAD;
import static com.project.backend.common.response.ResponseCode.SUCCESS_RECORD_UPLOAD;

@RestController
@RequestMapping("/api/climbing/record")
@RequiredArgsConstructor
public class RecordController {

    private final ClimbingRecordServiceImpl climbingRecordService;
    private final S3UploadService s3UploadService;

    @PostMapping("/save")
    public ResponseEntity<?> saveRecord(@AuthenticationPrincipal CustomUserDetails userDetails ,@ModelAttribute RecordSaveRequestDTO requestDTO) {

        Long userId = userDetails.getUser().getId();
        s3UploadService.checkFileTypeOrThrow(requestDTO.getFile()); // 파일 타입 체크
        s3UploadService.checkFileSizeOrThrow(requestDTO.getFile()); // 파일 크기 체크

        // 파일 비어있으면 오류 추가
        if (requestDTO.getFile().isEmpty()) {
            throw new CustomException(ResponseCode.EMPTY_FILE);
        }

        Optional<ClimbingRecord> optionalClimbingRecord = climbingRecordService.saveRecord(userId,requestDTO); // 기록부터 일단 저장
        ClimbingRecord climbingRecord;

        if (optionalClimbingRecord.isPresent()) {
            climbingRecord = optionalClimbingRecord.get();
        } else {
            throw new CustomException(ResponseCode.NOT_FOUND_CLIMB_RECORD);
        }

        try {
            VideoSaveResponseDTO responseDTO = s3UploadService.saveFile(requestDTO.getFile(),climbingRecord);
            return new ResponseEntity<>(Response.create(SUCCESS_FILE_UPLOAD, responseDTO), SUCCESS_FILE_UPLOAD.getHttpStatus());
        } catch (IOException e) {
//                e.printStackTrace();
            throw new CustomException(ResponseCode.FILE_UPLOAD_FAILED);
        }
    }

}
