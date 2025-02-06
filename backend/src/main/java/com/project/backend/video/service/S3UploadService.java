package com.project.backend.video.service;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.project.backend.common.advice.exception.CustomException;
import com.project.backend.common.response.ResponseCode;
import lombok.AllArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@Service
@RequiredArgsConstructor
public class S3UploadService {


    private final AmazonS3 amazonS3;

    private static final long MAX_FILE_SIZE = 1024L * 1024L * 1024L * 10L; // 10GB

    @Value("${cloud.aws.s3.bucket}")
    private String bucket;

    public String saveFile(MultipartFile multipartFile) throws IOException {

        checkFileTypeOrThrow(multipartFile); // 파일 타입 체크
        checkFileSizeOrThrow(multipartFile); // 파일 크기 체크

        String originalFilename = multipartFile.getOriginalFilename();

        ObjectMetadata objectMetadata = new ObjectMetadata();
        objectMetadata.setContentLength(multipartFile.getSize());
        objectMetadata.setContentType(multipartFile.getContentType());

        amazonS3.putObject(bucket, originalFilename, multipartFile.getInputStream(), objectMetadata);
        return amazonS3.getUrl(bucket, originalFilename).toString();
    }

    /*
     * 파일 타입 MP4인지 확인
     */
    private void checkFileTypeOrThrow(MultipartFile file) {
        String contentType = file.getContentType();
        if (!contentType.equals("video/mp4")){
            throw new CustomException(ResponseCode.INVALID_FILETYPE);
        }
    }

    /*
     * 파일 사이즈가 10GB 이상인지 확인
     */
    private void checkFileSizeOrThrow(MultipartFile file) {
        long fileSize = file.getSize();
        if (fileSize > MAX_FILE_SIZE){
            throw new CustomException(ResponseCode.FILE_SIZE_EXCEEDED);
        }
    }
}
