package com.project.backend.userdate.controller;

import com.project.backend.common.response.Response;
import com.project.backend.user.auth.CustomUserDetails;
import com.project.backend.userdate.dto.response.AlbumResponseDTO;
import com.project.backend.userdate.service.AlbumService;
import lombok.AllArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.time.LocalDate;

import static com.project.backend.common.response.ResponseCode.*;

@RestController
@RequestMapping("/api/album")
@RequiredArgsConstructor
public class AlbumController {

    private final AlbumService albumService;

    @GetMapping("/daily")
    ResponseEntity<?> getAlbumDaily(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam(name = "date") LocalDate date,
            @RequestParam(name = "isSuccess") Boolean isSuccess
    ) {
        Long userId = userDetails.getUser().getId();
        AlbumResponseDTO responseDTO= albumService.getAlbum(userId,date, isSuccess);

        if(responseDTO.getAlbumObject().isEmpty()) {
            return new ResponseEntity<>(Response.create(NO_CONTENT_ALBUM, responseDTO), NO_CONTENT_ALBUM.getHttpStatus());
        }
        return new ResponseEntity<>(Response.create(GET_ALBUM, responseDTO), GET_ALBUM.getHttpStatus());
    }
}
