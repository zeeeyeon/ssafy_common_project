package com.project.backend.oauth.utils;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.*;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.module.SimpleModule;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.oauth2.core.endpoint.OAuth2AuthorizationRequest;
import org.springframework.security.oauth2.core.endpoint.OAuth2AuthorizationResponseType;

import java.io.IOException;
import java.util.*;

public class CookieUtil {

  private static final ObjectMapper MAPPER = new ObjectMapper()
          .registerModule(new JavaTimeModule())
          .registerModule(new SimpleModule()
                  .addDeserializer(OAuth2AuthorizationRequest.class, new OAuth2AuthorizationRequestDeserializer())
                  .addDeserializer(OAuth2AuthorizationResponseType.class, new OAuth2ResponseTypeDeserializer()))
          .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

  private static final Logger log = LoggerFactory.getLogger(CookieUtil.class);

  public static Optional<Cookie> getCookie(HttpServletRequest request, String name) {
    Cookie[] cookies = request.getCookies();

    if (cookies != null) {
      for (Cookie cookie : cookies) {
        if (name.equals(cookie.getName())) {
          return Optional.of(cookie);
        }
      }
    }
    return Optional.empty();
  }

  public static void addCookie(HttpServletResponse response, String name, String value, int maxAge) {
    Cookie cookie = new Cookie(name, value);
    cookie.setPath("/");
    cookie.setHttpOnly(true);
    cookie.setMaxAge(maxAge);
    cookie.setSecure(true); // HTTPS만 사용

    response.addCookie(cookie);
  }

  public static void deleteCookie(HttpServletRequest request, HttpServletResponse response, String name) {
    Cookie[] cookies = request.getCookies();

    if (cookies != null) {
      for (Cookie cookie : cookies) {
        if (cookie.getName().equals(name)) {
          cookie.setValue("");
          cookie.setPath("/");
          cookie.setMaxAge(0);
          response.addCookie(cookie);
        }
      }
    }
  }

  public static String serialize(Object obj) {
    try {
      String jsonStr = MAPPER.writeValueAsString(obj);
      return Base64.getUrlEncoder().encodeToString(jsonStr.getBytes());
    } catch (JsonProcessingException e) {
      log.error("Failed to serialize object", e);
      throw new RuntimeException("Failed to serialize object", e);
    }
  }

  public static <T> T deserialize(Cookie cookie, Class<T> cls) {
    try {
      byte[] decodedBytes = Base64.getUrlDecoder().decode(cookie.getValue());
      String jsonStr = new String(decodedBytes);
      return MAPPER.readValue(jsonStr, cls);
    } catch (IOException e) {
      log.error("Failed to deserialize cookie value", e);
      throw new RuntimeException("Failed to deserialize cookie value", e);
    }
  }
}

// OAuth2AuthorizationResponseType를 위한 수정된 커스텀 Deserializer
class OAuth2ResponseTypeDeserializer extends JsonDeserializer<OAuth2AuthorizationResponseType> {
  @Override
  public OAuth2AuthorizationResponseType deserialize(JsonParser p,
                                                     DeserializationContext ctxt) throws IOException {
    String value = p.getValueAsString();
    if (value == null) {
      return null; // null 값 처리 추가
    }
    if ("code".equals(value)) {
      return OAuth2AuthorizationResponseType.CODE;
    }
    throw new IllegalArgumentException("Unknown OAuth2AuthorizationResponseType: " + value);
  }
}

@JsonDeserialize(builder = OAuth2AuthorizationRequest.Builder.class)
class OAuth2AuthorizationRequestDeserializer extends JsonDeserializer<OAuth2AuthorizationRequest> {
  @Override
  public OAuth2AuthorizationRequest deserialize(JsonParser p, DeserializationContext ctxt) throws IOException {
    ObjectMapper mapper = (ObjectMapper) p.getCodec();
    JsonNode node = mapper.readTree(p);

    return OAuth2AuthorizationRequest.authorizationCode()
            .authorizationUri(node.get("authorizationUri").asText())
            .clientId(node.get("clientId").asText())
            .redirectUri(node.get("redirectUri").asText())
            .scopes(getScopes(node))
            .state(node.get("state").asText())
            .attributes(getAttributes(node))
            .build();
  }

  private Set<String> getScopes(JsonNode node) {
    Set<String> scopes = new HashSet<>();
    if (node.has("scopes")) {
      node.get("scopes").forEach(scope -> scopes.add(scope.asText()));
    }
    return scopes;
  }

  private Map<String, Object> getAttributes(JsonNode node) {
    Map<String, Object> attributes = new HashMap<>();
    if (node.has("attributes")) {
      node.get("attributes").fields().forEachRemaining(entry ->
              attributes.put(entry.getKey(), entry.getValue().asText()));
    }
    return attributes;
  }
}