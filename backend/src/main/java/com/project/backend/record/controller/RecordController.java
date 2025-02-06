package com.project.backend.record.controller;

import com.project.backend.common.response.Response;
import com.project.backend.record.service.VideoUploadService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import static com.project.backend.common.response.ResponseCode.SUCCESS_FILE_UPLOAD;

@RestController
@RequestMapping("/api/climbing/record")
@RequiredArgsConstructor
public class RecordController {


//    private final RecordService recordService;
    private final VideoUploadService videoUploadService;

    @PostMapping("/save")
    public ResponseEntity<?> saveRecord(@RequestParam("file") MultipartFile file) {

        String filename = videoUploadService.upload(file);

        return new ResponseEntity<>(Response.create(SUCCESS_FILE_UPLOAD, filename), SUCCESS_FILE_UPLOAD.getHttpStatus());
    }
}
