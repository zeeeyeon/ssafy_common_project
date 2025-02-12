package com.project.backend.climbground.controller;

import com.amazonaws.services.s3.model.S3ObjectInputStream;
import com.project.backend.climbground.dto.responseDTO.GlbFileResponseDTO;
import com.project.backend.climbground.entity.GlbFile;
import com.project.backend.climbground.service.GlbFileService;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.InputStreamResource;
import org.springframework.core.io.Resource;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import static com.project.backend.common.response.Response.*;
import static com.project.backend.common.response.ResponseCode.GET_CLIMB_GROUND_3D;

@RestController
@RequestMapping("/api/climbground/glb")
@RequiredArgsConstructor
public class GlbFileController {

    private final GlbFileService glbFileService;

    // Create - 파일 업로드
    @PostMapping("/{climbgroundId}")
    public ResponseEntity<?> uploadGlb(@PathVariable(name ="climbgroundId") Long climbgroundId, @RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body("파일이 존재하지 않습니다.");
        }
        GlbFile savedFile = glbFileService.saveFile(climbgroundId, file);
        GlbFileResponseDTO resposneDto = new GlbFileResponseDTO(savedFile);
        return new ResponseEntity<>(create(GET_CLIMB_GROUND_3D, resposneDto), GET_CLIMB_GROUND_3D.getHttpStatus());
    }

    // Read - 파일 다운로드
    @GetMapping("/{id}/download")
    public ResponseEntity<Resource> getGlb(@PathVariable(name ="id") Long id) {
        S3ObjectInputStream s3is = glbFileService.loadFileAsResource(id);
        // InputStreamResource로 감싸서 반환
        Resource resource = new InputStreamResource(s3is);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + id + "\"")
                .body(resource);
    }

    // Read - 파일 조회
    @GetMapping("/{id}")
    public ResponseEntity<?> readGlbUrl(@PathVariable(name ="id") Long glbFileId) {
        GlbFile findFile = glbFileService.findFile(glbFileId);
        GlbFileResponseDTO resposneDto = new GlbFileResponseDTO(findFile);
        return new ResponseEntity<>(create(GET_CLIMB_GROUND_3D, resposneDto), GET_CLIMB_GROUND_3D.getHttpStatus());
    }

    // Update - 파일 수정
    @PutMapping("/{id}")
    public ResponseEntity<?> updateGlb(@PathVariable(name ="id") Long id, @RequestParam("file") MultipartFile file) {
        GlbFile updatedFile = glbFileService.updateFile(id, file);
        return ResponseEntity.ok(updatedFile);
    }

    // Delete - 파일 삭제
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteGlb(@PathVariable(name ="id") Long id) {
        glbFileService.deleteFile(id);
        return ResponseEntity.ok("파일이 삭제되었습니다.");
    }
}
