package com.project.backend.record.controller;

import com.project.backend.common.advice.exception.CustomException;
import com.project.backend.common.response.Response;
import com.project.backend.common.response.ResponseCode;
import com.project.backend.record.dto.requestDTO.RecordSaveRequestDTO;
import com.project.backend.record.service.VideoUploadService;
import com.project.backend.video.service.S3UploadService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

import static com.project.backend.common.response.ResponseCode.SUCCESS_FILE_UPLOAD;

@RestController
@RequestMapping("/api/climbing/record")
@RequiredArgsConstructor
public class RecordController {

//    private final RecordService recordService;
    private final S3UploadService s3UploadService;
    private final VideoUploadService videoUploadService;

    @PostMapping("/save")
    public ResponseEntity<?> saveRecord(@RequestBody RecordSaveRequestDTO requestDTO) {

        if (requestDTO.getIsSuccess()){

        }

        try {
            String filename = s3UploadService.saveFile(requestDTO.getFile());
            return new ResponseEntity<>(Response.create(SUCCESS_FILE_UPLOAD, filename), SUCCESS_FILE_UPLOAD.getHttpStatus());
        } catch (IOException e) {
            e.printStackTrace();
            throw new CustomException(ResponseCode.FILE_UPLOAD_FAILED);
        }

    }

}
