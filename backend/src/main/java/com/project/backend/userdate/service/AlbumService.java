package com.project.backend.userdate.service;

import com.project.backend.climbground.dto.responseDTO.LockClimbGroundAllResponseDTO;
import com.project.backend.userdate.dto.response.AlbumObjcet;
import com.project.backend.userdate.dto.response.AlbumResponseDTO;
import com.project.backend.userdate.entity.UserDate;
import com.project.backend.userdate.repository.UserDateRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AlbumService {

    private final UserDateRepository userDateRepository;

    public AlbumResponseDTO getAlbum(Long userId, LocalDate date, Boolean isSuccess) {
        LocalDateTime startOfDay = date.atStartOfDay();
        LocalDateTime endOfDay = date.atTime(LocalTime.MAX);

        AlbumResponseDTO albumResponseDTO = new AlbumResponseDTO(date,isSuccess);
        List<AlbumObjcet> albumObjcetList = userDateRepository.findUserDatesByUserAndClimbGroundAndIsSuccess(userId, startOfDay,endOfDay, isSuccess)
                .stream()
                .flatMap(userDate ->  userDate.getClimbingRecordList().stream().map(
                            climbingRecord ->
                                new AlbumObjcet(
                                        userDate.getUserClimbGround().getClimbGround().getName(),
                                        climbingRecord.getHold().getColor(),
                                        climbingRecord.getHold().getLevel(),
                                        climbingRecord.getVideo().getUrl()
                                ))).collect(Collectors.toList());

        List<AlbumObjcet> sortedAlbumObjcetList = albumObjcetList.stream()
                .sorted(Comparator.comparing(AlbumObjcet::getLevel))
                .collect(Collectors.toList());
        albumResponseDTO.setAlbumObject(sortedAlbumObjcetList);
        return albumResponseDTO;
    }
}
