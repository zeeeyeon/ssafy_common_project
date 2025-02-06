package com.project.backend.oauth.handler;

import com.project.backend.config.properties.AppProperties;
import com.project.backend.oauth.info.OAuth2UserInfo;
import com.project.backend.oauth.info.OAuth2UserInfoFactory;
import com.project.backend.oauth.repository.OAuth2AuthorizationRequestBasedOnCookieRepository;
import com.project.backend.oauth.token.AuthToken;
import com.project.backend.oauth.token.AuthTokenProvider;
import com.project.backend.oauth.utils.CookieUtil;
import com.project.backend.user.entity.UserProviderEnum;
import com.project.backend.user.entity.UserRefreshToken;
import com.project.backend.user.entity.UserRoleEnum;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.IOException;
import java.net.URI;
import java.util.Collection;
import java.util.Date;
import java.util.Optional;

import static com.project.backend.oauth.repository.OAuth2AuthorizationRequestBasedOnCookieRepository.REDIRECT_URI_PARAM_COOKIE_NAME;
import static org.springframework.security.oauth2.core.endpoint.OAuth2ParameterNames.REFRESH_TOKEN;

//@Component
//@RequiredArgsConstructor
//public class OAuth2AuthenticationSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {
//
//    private final AuthTokenProvider tokenProvider;
//    private final AppProperties appProperties;
//    private final UserRefreshTokenRepository userRefreshTokenRepository;
//    private final OAuth2AuthorizationRequestBasedOnCookieRepository authorizationRequestRepository;
//
//    @Override
//    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws IOException, ServletException {
//        String targetUrl = determineTargetUrl(request, response, authentication);
//
//        if (response.isCommitted()) {
//            logger.debug("Response has already been committed. Unable to redirect to " + targetUrl);
//            return;
//        }
//
//        clearAuthenticationAttributes(request, response);
//        getRedirectStrategy().sendRedirect(request, response, targetUrl);
//    }
//
//    protected String determineTargetUrl(HttpServletRequest request, HttpServletResponse response, Authentication authentication) {
//        Optional<String> redirectUri = CookieUtil.getCookie(request, REDIRECT_URI_PARAM_COOKIE_NAME)
//                .map(Cookie::getValue);
//
//        if(redirectUri.isPresent() && !isAuthorizedRedirectUri(redirectUri.get())) {
//            throw new IllegalArgumentException("Sorry! We've got an Unauthorized Redirect URI and can't proceed with the authentication");
//        }
//
//        String targetUrl = redirectUri.orElse(getDefaultTargetUrl());
//
//        OAuth2AuthenticationToken authToken = (OAuth2AuthenticationToken) authentication;
//        UserProviderEnum providerType = UserProviderEnum.valueOf(authToken.getAuthorizedClientRegistrationId().toUpperCase());
//
//        OidcUser user = ((OidcUser) authentication.getPrincipal());
//        OAuth2UserInfo userInfo = OAuth2UserInfoFactory.getOAuth2UserInfo(providerType, user.getAttributes());
//
//        Date now = new Date();
//        AuthToken accessToken = tokenProvider.createAuthToken(
//                userInfo.getName(),
//                UserRoleEnum.USER.getCode(),
//                new Date(now.getTime() + appProperties.getAuth().getTokenExpiry())
//        );
//
//        // refresh 토큰 설정
//        long refreshTokenExpiry = appProperties.getAuth().getRefreshTokenExpiry();
//
//        AuthToken refreshToken = tokenProvider.createAuthToken(
//                appProperties.getAuth().getTokenSecret(),
//                new Date(now.getTime() + refreshTokenExpiry)
//        );
//
//        // DB 저장
//        Optional<UserRefreshToken> optionalUserRefreshToken = userRefreshTokenRepository.findByUserName(userInfo.getName());
//
//        UserRefreshToken userRefreshToken;
//        if (optionalUserRefreshToken.isPresent()) {
//            userRefreshToken = optionalUserRefreshToken.get();
//            userRefreshToken.setRefreshToken(refreshToken.getToken());
//            userRefreshToken.setExpirationDate(new Date(now.getTime() + refreshTokenExpiry));
//        } else {
//            userRefreshToken = new UserRefreshToken();
//            userRefreshToken.setUserName(userInfo.getName());
//            userRefreshToken.setRefreshToken(refreshToken.getToken());
//            userRefreshToken.setExpirationDate(new Date(now.getTime() + refreshTokenExpiry));
//        }
//
//        userRefreshTokenRepository.save(userRefreshToken);
//
//        int cookieMaxAge = (int) refreshTokenExpiry / 60;
//
//        CookieUtil.deleteCookie(request, response, REFRESH_TOKEN);
//        CookieUtil.addCookie(response, REFRESH_TOKEN, refreshToken.getToken(), cookieMaxAge);
//
//        return UriComponentsBuilder.fromUriString(targetUrl)
//                .queryParam("token", accessToken.getToken())
//                .build().toUriString();
//    }
//
//    protected void clearAuthenticationAttributes(HttpServletRequest request, HttpServletResponse response) {
//        super.clearAuthenticationAttributes(request);
//        authorizationRequestRepository.removeAuthorizationRequestCookies(request, response);
//    }
//
//    private boolean hasAuthority(Collection<? extends GrantedAuthority> authorities, String authority) {
//        if (authorities == null) {
//            return false;
//        }
//
//        for (GrantedAuthority grantedAuthority : authorities) {
//            if (authority.equals(grantedAuthority.getAuthority())) {
//                return true;
//            }
//        }
//        return false;
//    }
//
//    private boolean isAuthorizedRedirectUri(String uri) {
//        URI clientRedirectUri = URI.create(uri);
//
//        return appProperties.getOauth2().getAuthorizedRedirectUris()
//                .stream()
//                .anyMatch(authorizedRedirectUri -> {
//                    // Only validate host and port. Let the clients use different paths if they want to
//                    URI authorizedURI = URI.create(authorizedRedirectUri);
//                    if(authorizedURI.getHost().equalsIgnoreCase(clientRedirectUri.getHost())
//                            && authorizedURI.getPort() == clientRedirectUri.getPort()) {
//                        return true;
//                    }
//                    return false;
//                });
//    }
//}
