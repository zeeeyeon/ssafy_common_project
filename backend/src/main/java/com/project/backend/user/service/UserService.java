package com.project.backend.user.service;

import com.project.backend.user.entity.User;
import com.project.backend.user.repository.jpa.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserService {
  private final UserRepository userRepository;

  public User getUserByUserName(String userName) {
    return userRepository.findByUsername(userName);
  }


}
