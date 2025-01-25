package com.project.backend.record.entity;

import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

public class Record {

    @Id
    @GeneratedValue( strategy = GenerationType.IDENTITY )
    private Long id;
    private boolean isSuccess;


}
