package com.project.backend.userdate.repository;

import com.project.backend.userdate.entity.UserDate;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserDateRepository extends JpaRepository<UserDate, Long> {
}
