package com.project.backend.oauth.info.impl;

import com.project.backend.oauth.info.OAuth2UserInfo;
import java.util.Map;

public class NaverOAuth2UserInfo extends OAuth2UserInfo {

    public NaverOAuth2UserInfo(Map<String, Object> attributes) {
        super(attributes);
    }

    /**
     * response 키로부터 Map<String, Object> 타입의 값을 안전하게 가져오고,
     * 아니면 null을 반환하는 메서드
     */
    @SuppressWarnings("unchecked")
    private Map<String, Object> getResponse() {
        Object responseObj = attributes.get("response");
        if (responseObj instanceof Map) {
            // 제네릭 타입 소거로 인해 컴파일러가 경고를 낼 수 있으므로,
            // 불가피하게 @SuppressWarnings("unchecked")를 사용
            return (Map<String, Object>) responseObj;
        }
        return null;
    }

    @Override
    public String getName() {
        Map<String, Object> response = getResponse();
        if (response == null) {
            return null;
        }
        return (String) response.get("name");
    }

    @Override
    public String getNickName() {
        Map<String, Object> response = getResponse();
        if (response == null) {
            return null;
        }
        return (String) response.get("nickname");
    }

    @Override
    public String getEmail() {
        Map<String, Object> response = getResponse();
        if (response == null) {
            return null;
        }
        return (String) response.get("email");
    }

    @Override
    public String getImageUrl() {
        Map<String, Object> response = getResponse();
        if (response == null) {
            return null;
        }
        return (String) response.get("profile_image");
    }
}
