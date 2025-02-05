package com.project.backend.record.service;

import com.project.backend.common.advice.exception.CustomException;
import com.project.backend.common.response.ResponseCode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;


import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@Service
@Slf4j
public class VideoUploadService {

    private static final long MAX_FILE_SIZE = 1024L * 1024L * 1024L * 10L; // 10GB

    public String upload(MultipartFile file) {

        checkFileTypeOrThrow(file);
        checkFileSizeOrThrow(file);

        String fileName = UUID.randomUUID() + ".mp4";

        String directoryPath = getDirectoryPath();
        Path filePath = Paths.get(directoryPath, fileName);

        try (OutputStream os = Files.newOutputStream(filePath)) {
            os.write(file.getBytes());
            return fileName;
        } catch (Exception e) {
            log.error(" 파일 업로드 에러",e);
            throw new CustomException(ResponseCode.FILE_UPLOAD_FAILED);
        }


    }


    /*
     * 파일 저장 디렉토리 경로를 가져오고 없으면 생성하기
     */
    private String getDirectoryPath(){
        String directory = "src/main/resources/static/video";
        Path dircetoryPath = Paths.get(directory);
        if (!Files.exists(dircetoryPath)) {
            try {
                Files.createDirectories(dircetoryPath);
            } catch (Exception e) {
                log.error("파일 로드 실패",e);
                throw new CustomException(ResponseCode.FILE_UPLOAD_FAILED);
            }
        }
        return dircetoryPath.toString();
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

