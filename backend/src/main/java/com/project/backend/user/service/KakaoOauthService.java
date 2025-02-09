package com.project.backend.user.service;

import com.project.backend.user.dto.KakaoTokenResponseDto;
import com.project.backend.user.dto.KakaoUserInfoDto;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

@Service
@RequiredArgsConstructor
public class KakaoOauthService {

  private final RestTemplate restTemplate = new RestTemplate();
  private final Logger log = LoggerFactory.getLogger(getClass());

  @Value("${kakao.client-id}")
  private String clientId;

  @Value(("${kakao.redirect-uri}"))
  private String redirectUri;

  @Value("${kakao.client-secret}")
  private String clientSecret;

  // 카카오 API URL
  private static final String AUTHORIZATION_URL = "https://kauth.kakao.com/oauth/authorize";
  private static final String TOKEN_URL = "https://kauth.kakao.com/oauth/token";
  private static final String USER_INFO_URL = "https://kapi.kakao.com/v2/user/me";

  public String getAuthorizationUrl() {
    return UriComponentsBuilder.fromHttpUrl(AUTHORIZATION_URL)
            .queryParam("client_id", clientId)
            .queryParam("redirect_uri", redirectUri)
            .queryParam("response_type", "code")
            .toUriString();
  }

  // 인가 코드로 토큰 교환
  public KakaoTokenResponseDto getAccessToken(String code) {
    HttpHeaders headers = new HttpHeaders();
    headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

    MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
    params.add("grant_type", "authorization_code");
    params.add("client_id", clientId);
    params.add("redirect_uri", redirectUri);
    params.add("client_secret", clientSecret);
    params.add("code", code);

    HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(params, headers);
    try {
      ResponseEntity<KakaoTokenResponseDto> response = restTemplate.postForEntity(TOKEN_URL, request, KakaoTokenResponseDto.class);
      return response.getBody();
    } catch (HttpClientErrorException e) {
      log.error("카카오 토큰 요청 에러: {}", e.getResponseBodyAsString());
      throw e;
    }
  }

  // 카카오 사용자 정보 요청
  public KakaoUserInfoDto getUserInfo(String accessToken) {
    HttpHeaders headers = new HttpHeaders();
    headers.add("Authorization", "Bearer " + accessToken);
    HttpEntity<?> request = new HttpEntity<>(headers);
    //
    ResponseEntity<KakaoUserInfoDto> response = restTemplate.exchange(USER_INFO_URL, HttpMethod.GET, request, KakaoUserInfoDto.class);
    return response.getBody();
  }
}
