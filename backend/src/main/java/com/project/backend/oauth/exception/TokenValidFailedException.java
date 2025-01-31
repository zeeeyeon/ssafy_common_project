package com.project.backend.oauth.exception;

public class TokenValidFailedException extends RuntimeException {

  public TokenValidFailedException() {
    super("Failed to generate Token.");
  }
}
