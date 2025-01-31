package com.project.backend.oauth.info;

import com.project.backend.oauth.info.impl.GoogleOAuth2UserInfo;
import com.project.backend.oauth.info.impl.NaverOAuth2UserInfo;
import com.project.backend.user.entity.UserProviderEnum;

import java.util.Map;

public class OAuth2UserInfoFactory {
    public static OAuth2UserInfo getOAuth2UserInfo(UserProviderEnum providerType, Map<String, Object> attributes) {
        switch(providerType) {
            case GOOGLE: return new GoogleOAuth2UserInfo(attributes);
            case NAVER: return new NaverOAuth2UserInfo(attributes);
            default: throw new IllegalArgumentException("Invalid Provider Type. ");
        }
    }
}
