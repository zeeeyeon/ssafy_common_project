package com.project.backend.oauth.service;

import com.project.backend.oauth.entity.UserPrincipal;
import com.project.backend.oauth.exception.OAuthProviderMissMatchException;
import com.project.backend.oauth.info.OAuth2UserInfo;
import com.project.backend.oauth.info.OAuth2UserInfoFactory;
import com.project.backend.user.entity.User;
import com.project.backend.user.entity.UserProviderEnum;
import com.project.backend.user.entity.UserRoleEnum;
import com.project.backend.user.repository.jpa.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.InternalAuthenticationServiceException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    private final UserRepository userRepository;

    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User user = super.loadUser(userRequest);

        try {
            return this.process(userRequest, user);
        } catch(AuthenticationException ex) {
            throw ex;
        } catch (Exception ex) {
            ex.printStackTrace();
            throw new InternalAuthenticationServiceException(ex.getMessage(), ex.getCause());
        }
    }

    private OAuth2User process(OAuth2UserRequest userRequest, OAuth2User user) {
        UserProviderEnum providerType = UserProviderEnum.valueOf(userRequest.getClientRegistration().getRegistrationId().toUpperCase());

        OAuth2UserInfo userInfo = OAuth2UserInfoFactory.getOAuth2UserInfo(providerType, user.getAttributes());
        User savedUser = userRepository.findByUsername(userInfo.getName());

        String email = userInfo.getEmail() != null ? userInfo.getEmail() : "default@example.com"; // 기본값 설정

        if (savedUser != null) {
            if(providerType != savedUser.getProviderType()) {
                throw new OAuthProviderMissMatchException(
                        "Looks like you're signed up with " + providerType +
                        " account. Please use your " + savedUser.getProviderType() + " account to login."
                );
            }
            updateUser(savedUser, userInfo);
        } else {
            savedUser = createUser(userInfo, providerType, email);
        }

        // 리턴된 UserDetails 객체는 사용자 인증 정보를 나타내기 위해 Authentication 객체에 담겨지고,
        // 이 Authentication 객체는 사용자의 인증 상태를 나타내며, SecurityContext에 저장된다.
        return UserPrincipal.create(savedUser, user.getAttributes());
    }

    private User createUser(OAuth2UserInfo userInfo, UserProviderEnum providerType, String email) {

        User user = User.builder()
                .username(userInfo.getName())
                .nickname(userInfo.getNickName())
                .email(email)
                .emailVerifiedYn("Y")
                .profileImageUrl(userInfo.getImageUrl())
                .providerType(providerType)
                .roleType(UserRoleEnum.USER)
                .createDate(LocalDateTime.now())
                .updateDate(LocalDateTime.now())
                .build();

        return userRepository.saveAndFlush(user);
    }

    private User updateUser(User user, OAuth2UserInfo userInfo) {
        if(userInfo.getName() != null && !user.getUsername().equals(userInfo.getName())) {
            user.setUsername(userInfo.getName());
        }

        if(userInfo.getImageUrl() != null && !user.getProfileImageUrl().equals(userInfo.getImageUrl())) {
            user.setProfileImageUrl(userInfo.getImageUrl());
        }

        return user;
    }
}

