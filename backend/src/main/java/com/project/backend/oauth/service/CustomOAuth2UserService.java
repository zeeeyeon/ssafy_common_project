package com.project.backend.oauth.service;

import com.project.backend.oauth.entity.UserPrincipal;
import com.project.backend.user.entity.User;
import com.project.backend.user.entity.UserProviderEnum;
import com.project.backend.user.entity.UserRoleEnum;
import com.project.backend.user.repository.jpa.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.InternalAuthenticationServiceException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    private final UserRepository userRepository;

    /**
     * OAuth2 로그인 시에 Spring Security가 자동으로 호출하는 메서드.
     * super.loadUser()를 통해 Google에서 사용자 정보를 받아온다.
     */
    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User oauth2User = super.loadUser(userRequest);

        try {
            return this.process(userRequest, oauth2User);
        } catch (AuthenticationException ex) {
            throw ex;
        } catch (Exception ex) {
            ex.printStackTrace();
            throw new InternalAuthenticationServiceException(ex.getMessage(), ex);
        }
    }

    /**
     * userRequest(구글 OAuth2 정보), 구글이 준 사용자 정보(oauth2User)를 기반으로
     * 가입된 회원인지 조회 후, 없다면 회원가입을 진행 후
     * CustomOAuth2User를 생성해 리턴합니다.
     */
    private OAuth2User process(OAuth2UserRequest userRequest, OAuth2User oauth2User) {
        String registrationId = userRequest.getClientRegistration().getRegistrationId();
        String email = getEmailFromGoogle(oauth2User);

        Optional<User> optionalUser = userRepository.findByEmail(email);

        User userEntity;
        if (optionalUser.isEmpty()) {
            userEntity = User.builder()
                    .email(email)
                    .username((String) oauth2User.getAttributes().get("name"))
                    .roleType(UserRoleEnum.valueOf("USER"))
                    .providerType(UserProviderEnum.valueOf(registrationId.toUpperCase())) // GOOGLE
                    .build();
            userEntity = userRepository.save(userEntity);
        } else {
            userEntity = optionalUser.get();
        }

        // 기존 CustomOAuth2User 대신 UserPrincipal 사용
        return UserPrincipal.create(userEntity, oauth2User.getAttributes());
    }

    /**
     * 구글 OAuth2User에서 이메일을 추출하는 간단한 메서드.
     * 구글은 기본적으로 "email" 키에 이메일이 담겨 있습니다.
     */
    private String getEmailFromGoogle(OAuth2User oauth2User) {
        Map<String, Object> attributes = oauth2User.getAttributes();
        return (String) attributes.get("email");
    }
}


