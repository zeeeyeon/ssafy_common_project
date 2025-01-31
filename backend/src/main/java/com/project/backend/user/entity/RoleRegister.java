package com.project.backend.user.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@Entity(name = "roleRegister")
@Table(name = "role_register")
public class RoleRegister {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long roleRegisterId;
    private Long userId;
    private Long roleId;
    private LocalDateTime createDate;
    private LocalDateTime updateDate;
}
