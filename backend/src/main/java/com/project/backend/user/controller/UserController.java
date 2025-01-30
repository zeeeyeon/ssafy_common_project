package com.project.backend.user.controller;

import com.project.backend.oauth.common.ApiResponse;
import com.project.backend.oauth.entity.UserPrincipal;
import com.project.backend.user.entity.User;
import com.project.backend.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {

  private final UserService userService;

  @GetMapping
  public ApiResponse getUser() {
    Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();

    if (principal instanceof UserPrincipal userPrincipal) {
      User user = userService.getUserByUserName(userPrincipal.getUsername());
      return ApiResponse.success("user", user);
    } else if (principal instanceof User user) {
      return ApiResponse.success("user", user);
    }

    throw new RuntimeException("Unexpected principal type: " + principal.getClass());
  }
}
