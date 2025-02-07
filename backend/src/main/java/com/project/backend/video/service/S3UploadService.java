package com.project.backend.video.service;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.project.backend.common.advice.exception.CustomException;
import com.project.backend.common.response.ResponseCode;
import com.project.backend.record.entity.ClimbingRecord;
import com.project.backend.video.dto.responseDTO.VideoSaveResponseDTO;
import com.project.backend.video.entity.Video;
import com.project.backend.video.repository.VideoRepository;
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

    private final VideoRepository videoRepository;

    private final AmazonS3 amazonS3;

    private static final long MAX_FILE_SIZE = 1024L * 1024L * 1024L * 10L; // 10GB

    @Value("${cloud.aws.s3.bucket}")
    private String bucket;

    public VideoSaveResponseDTO saveFile(MultipartFile multipartFile, ClimbingRecord climbingRecord) throws IOException {


        String originalFilename = multipartFile.getOriginalFilename();

        ObjectMetadata objectMetadata = new ObjectMetadata();
        objectMetadata.setContentLength(multipartFile.getSize());
        objectMetadata.setContentType(multipartFile.getContentType());

        amazonS3.putObject(bucket, originalFilename, multipartFile.getInputStream(), objectMetadata);
        String url = amazonS3.getUrl(bucket, originalFilename).toString();

        //비디오 테이블에 영상 url 저장
        Video newVideo = new Video();
        newVideo.setClimbingRecord(climbingRecord);
        newVideo.setUrl(url);
        VideoSaveResponseDTO videoSaveResponseDTO = new VideoSaveResponseDTO(
                newVideo.getId(), url, climbingRecord.getId()
        );
        videoRepository.save(newVideo);

        return videoSaveResponseDTO;
    }

    /*
     * 파일 타입 MP4인지 확인
     */
    public void checkFileTypeOrThrow(MultipartFile file) {
        String contentType = file.getContentType();
        if (!contentType.equals("video/mp4")){
            throw new CustomException(ResponseCode.INVALID_FILETYPE);
        }
    }

    /*
     * 파일 사이즈가 10GB 이상인지 확인
     */
    public void checkFileSizeOrThrow(MultipartFile file) {
        long fileSize = file.getSize();
        if (fileSize > MAX_FILE_SIZE){
            throw new CustomException(ResponseCode.FILE_SIZE_EXCEEDED);
        }
    }
}
