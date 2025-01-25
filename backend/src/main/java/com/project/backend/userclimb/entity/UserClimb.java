package com.project.backend.userclimb.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;

@Entity
public class UserClimb {

    @Id
    private Long id;

    private UserClimbMedalEnum medal;


}
