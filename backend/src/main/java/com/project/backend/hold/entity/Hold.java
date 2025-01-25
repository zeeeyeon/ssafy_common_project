package com.project.backend.hold.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

@Entity
public class Hold {
    @Id
    @GeneratedValue( strategy = GenerationType.IDENTITY )
    private Long id;
    private HoldLevelEnum level;
    private HoldColorEnum color;
}

