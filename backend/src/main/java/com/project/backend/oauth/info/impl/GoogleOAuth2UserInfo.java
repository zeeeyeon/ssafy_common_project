package com.project.backend.oauth.info.impl;


import com.project.backend.oauth.info.OAuth2UserInfo;

import java.util.Map;

/**
 * 인증 객체인 Authentication 객체 안에 사용자 정보를 담기 위한 클래스로,
 * gradle에 추가한 OAuth2 Client가 제공하는 OAuth2User 인터페이스의 구현체로 작성해야
 * Authentication 객체 안에 담을 수 있기 때문에 OAuth2User를 구현하여 getter를
 * 오버라이딩하였습니다.
 */
public class GoogleOAuth2UserInfo extends OAuth2UserInfo {

    public GoogleOAuth2UserInfo(Map<String, Object> attributes) {
        super(attributes);
    }

    @Override
    public String getName() {
        return (String) attributes.get("sub");
    }

    @Override
    public String getNickName() {
        return (String) attributes.get("name");
    }

    @Override
    public String getEmail() {
        return (String) attributes.get("email");
    }

    @Override
    public String getImageUrl() {
        return (String) attributes.get("picture");
    }
}
