package com.project.backend.user.repository.jpa;

import com.project.backend.user.entity.RoleRegister;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RoleRegisterRepository extends JpaRepository<RoleRegister, Long> {
}
