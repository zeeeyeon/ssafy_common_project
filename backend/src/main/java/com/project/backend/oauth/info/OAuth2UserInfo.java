package com.project.backend.oauth.info;

import lombok.Getter;

import java.util.Map;

@Getter
public abstract class OAuth2UserInfo {

  protected Map<String, Object> attributes;

  public OAuth2UserInfo(Map<String, Object> attributes) {
    this.attributes = attributes;
  }

  public abstract String getName(); // 유저 이름

  public abstract String getNickName(); // 유저 닉네임

  public abstract String getEmail();

  public abstract String getImageUrl();

}
