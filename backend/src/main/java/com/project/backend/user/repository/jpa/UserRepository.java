package com.project.backend.user.repository.jpa;

import com.project.backend.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
  User findByUsername(String username);
  User findByEmail(String email);
  User findByPhone(String phone);
  User findByNickname(String nickname);
}
