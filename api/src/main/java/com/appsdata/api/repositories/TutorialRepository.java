package com.appsdata.api.repositories;

import org.springframework.data.jpa.repository.JpaRepository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import com.appsdata.api.entities.Tutorial;

// We create our repository, the <> typing defines the entity class acting as a schema, and type of the ID
public interface TutorialRepository extends JpaRepository<Tutorial, Integer> {

    // Add a method to search by 'Title' and factor in paging.
    Page<Tutorial> findByTitleIgnoreCaseContaining(String title, Pageable pageable);

}
