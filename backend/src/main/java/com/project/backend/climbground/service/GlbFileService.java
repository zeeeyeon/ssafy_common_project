package com.project.backend.climbground.service;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.s3.model.S3ObjectInputStream;
import com.project.backend.climbground.entity.ClimbGround;
import com.project.backend.climbground.entity.GlbFile;
import com.project.backend.climbground.repository.ClimbGroundRepository;
import com.project.backend.climbground.repository.GlbFileRepository;
import com.project.backend.common.advice.exception.CustomException;
import com.project.backend.common.response.ResponseCode;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Objects;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class GlbFileService {

    @Value("${cloud.aws.s3.bucket}")
    private String bucket;

    private final AmazonS3 amazonS3;
    private final GlbFileRepository glbFileRepository;
    private final ClimbGroundRepository climbGroundRepository; // 추가

    /**
     * GLB 파일 저장
     * 1. 파일 확장자 검증
     * 2. S3에 파일 업로드
     * 3. DB에 메타데이터 저장
     */
    public GlbFile saveFile(Long climbgroundId, MultipartFile file) {
        // 클라이밍장 존재 여부 확인
        ClimbGround climbGround = climbGroundRepository.findById(climbgroundId)
                .orElseThrow(() -> new RuntimeException("클라이밍장을 찾을 수 없습니다: " + climbgroundId));

        String fileName = StringUtils.cleanPath(Objects.requireNonNull(file.getOriginalFilename()));
        // 파일 확장자 체크 (.glb)
        if (!fileName.toLowerCase().endsWith(".glb")) {
            throw new RuntimeException("유효하지 않은 파일 형식입니다.");
        }

        try {
            // S3에 파일 업로드를 위한 메타데이터 설정
            ObjectMetadata metadata = new ObjectMetadata();
            metadata.setContentType("model/gltf-binary");
            metadata.setContentLength(file.getSize());

            // 파일명 중복 방지를 위한 UUID 추가
            String uniqueFileName = UUID.randomUUID().toString() + "_" + fileName;

            // S3 버킷에 파일 업로드
            amazonS3.putObject(bucket, uniqueFileName, file.getInputStream(), metadata);
            String url = amazonS3.getUrl(bucket, uniqueFileName).toString();

            // DB에 메타데이터 저장
            GlbFile glbFile = new GlbFile();
            glbFile.setFileName(uniqueFileName);
            glbFile.setFileType(file.getContentType());
            glbFile.setFilePath(url);
            glbFile.setClimbGround(climbGround);

            return glbFileRepository.save(glbFile);
        } catch (IOException ex) {
            throw new RuntimeException("파일 업로드에 실패했습니다: " + fileName, ex);
        }
    }

    // 파일 다운로드 (Read)
    public S3ObjectInputStream loadFileAsResource(Long id) {
        GlbFile glbFile = glbFileRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("파일을 찾을 수 없습니다: " + id));
        String key = glbFile.getFileName();
        S3Object s3Object = amazonS3.getObject(bucket, key);
        return s3Object.getObjectContent();
    }

    public GlbFile findFile(Long fileId) {
        return glbFileRepository.findById(fileId).orElseThrow(() -> new CustomException(ResponseCode.NO_EXISTED_GLB_FILE));
    }

    // 파일 수정 (Update)
    public GlbFile updateFile(Long id, MultipartFile file) {
        GlbFile existingFile = glbFileRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("파일을 찾을 수 없습니다: " + id));

        // 기존 파일 S3에서 삭제
        amazonS3.deleteObject(bucket, existingFile.getFileName());

        // 새 파일 업로드
        String fileName = StringUtils.cleanPath(Objects.requireNonNull(file.getOriginalFilename()));
        if (!fileName.toLowerCase().endsWith(".glb")) {
            throw new RuntimeException("유효하지 않은 파일 형식입니다.");
        }
        try {
            ObjectMetadata metadata = new ObjectMetadata();
            metadata.setContentType(file.getContentType());
            metadata.setContentLength(file.getSize());
            amazonS3.putObject(bucket, fileName, file.getInputStream(), metadata);
        } catch (IOException ex) {
            throw new RuntimeException("파일 업로드에 실패했습니다: " + fileName, ex);
        }

        existingFile.setFileName(fileName);
        existingFile.setFileType(file.getContentType());
        existingFile.setFilePath("s3://" + bucket + "/" + fileName);
        return glbFileRepository.save(existingFile);
    }

    // 파일 삭제 (Delete)
    public void deleteFile(Long id) {
        GlbFile glbFile = glbFileRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("파일을 찾을 수 없습니다: " + id));
        amazonS3.deleteObject(bucket, glbFile.getFileName());
        glbFileRepository.deleteById(id);
    }
}
