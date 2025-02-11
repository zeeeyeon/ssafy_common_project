package com.project.backend.video.service;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.project.backend.common.advice.exception.CustomException;
import com.project.backend.common.response.ResponseCode;
import com.project.backend.record.entity.ClimbingRecord;
import com.project.backend.video.dto.responseDTO.VideoSaveResponseDTO;
import com.project.backend.video.entity.Video;
import com.project.backend.video.repository.VideoRepository;
import lombok.RequiredArgsConstructor;
import org.apache.commons.io.FilenameUtils;
import org.jcodec.api.FrameGrab;
import org.jcodec.api.JCodecException;
import org.jcodec.common.io.FileChannelWrapper;
import org.jcodec.common.io.NIOUtils;
import org.jcodec.common.model.Picture;
import org.jcodec.scale.AWTUtil;
import org.joda.time.DateTime;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;

@Service
@RequiredArgsConstructor
public class S3UploadService {

    private final VideoRepository videoRepository;

    private final AmazonS3 amazonS3;

    @Value("${cloud.aws.s3.bucket}")
    private String bucket;

    private static final long MAX_FILE_SIZE = 1024L * 1024L * 1024L * 10L; // 10GB
    private static final long MAX_IMAGE_SIZE = 1024L * 1024L * 5L; // 10GB

    public VideoSaveResponseDTO saveFile(MultipartFile multipartFile, ClimbingRecord climbingRecord) throws IOException {


        String originalFilename = multipartFile.getOriginalFilename();

        String videoUrl = "video" +originalFilename + DateTime.now();
        ObjectMetadata objectMetadata = new ObjectMetadata();
        objectMetadata.setContentLength(multipartFile.getSize());
        objectMetadata.setContentType(multipartFile.getContentType());

        amazonS3.putObject(bucket, videoUrl, multipartFile.getInputStream(), objectMetadata);
        String url = amazonS3.getUrl(bucket, videoUrl).toString();

        // 썸네일 사진 추가
        String thumbnailName = "Thumb_" + DateTime.now() + FilenameUtils.getBaseName(originalFilename) + ".JPEG";
        String thumbnailURL = uploadThumbnail(multipartFile, thumbnailName);

        //비디오 테이블에 영상 url 저장
        Video newVideo = new Video();
        newVideo.setClimbingRecord(climbingRecord);
        newVideo.setUrl(url);

        newVideo.setThumbnail(thumbnailURL);

        VideoSaveResponseDTO videoSaveResponseDTO = new VideoSaveResponseDTO(
                newVideo.getId(), url, thumbnailURL,climbingRecord.getId()
        );
        videoRepository.save(newVideo);

        return videoSaveResponseDTO;
    }

    // 이미지 업로드 메서드: MultipartFile과 원하는 파일명을 전달받음
    public String saveImage(MultipartFile multipartFile, String imageName) throws IOException {
        ObjectMetadata objectMetadata = new ObjectMetadata();
        objectMetadata.setContentLength(multipartFile.getSize());
        objectMetadata.setContentType(multipartFile.getContentType());
        amazonS3.putObject(bucket, imageName, multipartFile.getInputStream(), objectMetadata);
        return amazonS3.getUrl(bucket, imageName).toString();
    }

    // 이미지 파일 타입이 JPEG 혹은 PNG 인지 확인
    public void checkImageFileTypeOrThrow(MultipartFile file) {
        String contentType = file.getContentType();
        if (!(contentType.equals("image/jpeg") || contentType.equals("image/png"))) {
            throw new CustomException(ResponseCode.INVALID_FILETYPE);
        }
    }

    // 이미지 파일 사이즈가 최대 허용 크기를 넘지 않는지 확인
    public void checkImageFileSizeOrThrow(MultipartFile file) {
        if (file.getSize() > MAX_IMAGE_SIZE) {
            throw new CustomException(ResponseCode.FILE_SIZE_EXCEEDED);
        }
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

    public String uploadThumbnail(MultipartFile multipartFile , String thumbnailName) throws IOException {

        File file = convertMultipartFileToFile(multipartFile);
        String thumbnailURL = getThumbnailURL(thumbnailName, file);
        try {
            Files.delete(Path.of(file.getPath()));
        } catch (IOException e) {
            System.out.print("파일이 삭제되지 않았습니다.");
            throw new RuntimeException(e);
        }
        return thumbnailURL;
    }

    private String getThumbnailURL(String thumbnailName, File file) {

        // Get image from video
        try (FileChannelWrapper fileChannelWrapper = NIOUtils.readableChannel(file);
             ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
            FrameGrab grab = FrameGrab.createFrameGrab(fileChannelWrapper);
            Picture picture = grab.seekToSecondPrecise(1.0).getNativeFrame();
            BufferedImage bufferedImage = AWTUtil.toBufferedImage(picture);

            // 이미지 메타 데이터 설정해야 url 접근시 다운안됨
            ObjectMetadata metadata = new ObjectMetadata();
            metadata.setContentType("image/jpeg");


            ImageIO.write(bufferedImage, "JPEG", baos); //여기에 바로 input
            baos.flush();
            InputStream is = new ByteArrayInputStream(baos.toByteArray());
            // Upload the object to S3
            amazonS3.putObject(new PutObjectRequest(bucket, thumbnailName, is, metadata));
            String url = amazonS3.getUrl(bucket, thumbnailName).toString();
            return url;
        } catch (JCodecException | IOException e) {
            throw new RuntimeException(e);
        }

    }


    private File convertMultipartFileToFile(MultipartFile multipartFile) throws IOException {
        File convFile = new File(multipartFile.getOriginalFilename());
        convFile.createNewFile();
        FileOutputStream fos = new FileOutputStream(convFile);
        fos.write(multipartFile.getBytes());
        fos.close();
        return convFile;

    }


}
