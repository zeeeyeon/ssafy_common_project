package com.project.backend.userdate.dto.response;

import com.project.backend.hold.entity.HoldColorEnum;
import com.project.backend.hold.entity.HoldLevelEnum;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class AlbumObjcet {

    private String name;
    private HoldColorEnum color;
    private HoldLevelEnum level;
    private String url;
    private String thumbnailUrl;

}
