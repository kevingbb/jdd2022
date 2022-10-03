package com.appsdata.api.controllers;

import java.util.ArrayList;
import java.util.Optional;

import com.appsdata.api.repositories.TutorialRepository;
import com.appsdata.api.entities.Tutorial;
import com.appsdata.api.entities.PagedTutorial;

import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

@Service
public class TutorialService 
{
    @Autowired
    private TutorialRepository Tutorial;
     
    public PagedTutorial getTutorials(String title, Integer page, Integer size, String sortBy) throws RuntimeException {
        try {
            Page<Tutorial> pagedResult = null;
            Pageable paging = PageRequest.of(page, size, Sort.by(sortBy));
            if (title.isEmpty()) {
                pagedResult = Tutorial.findAll(paging);
            }
            else {
                pagedResult = Tutorial.findByTitleIgnoreCaseContaining(title, paging);
            }
            Integer totalItems = (int)pagedResult.getTotalElements();
            Integer totalPages = (int)Math.ceil((double)totalItems / (double)size);
         
            if(pagedResult.hasContent()) {
                return new PagedTutorial(totalItems, pagedResult.getContent(), totalPages, page);
            }
            else {
                return new PagedTutorial(totalItems, new ArrayList<Tutorial>(), 0, 0);
            }
        }
        catch (RuntimeException exc) {
            throw new RuntimeException("Getting tutorials failed:" + exc.getMessage());
        }
    }

    public Tutorial getTutorial(Integer id) throws RuntimeException {
        Optional<Tutorial> tutorial = Tutorial.findById(id);

        if(tutorial.isPresent()) {
            return tutorial.get();
        }
        else {
            throw new RuntimeException("No tutorials record exist for given id:" + id);
        }
    }

    public String createTutorial(Tutorial newTutorial) throws RuntimeException {
        try {
            Tutorial.save(newTutorial); //creates new tutorial
            return "Tutorial was created successfully.";
        }
        catch (RuntimeException exc) {
            throw new RuntimeException("Create tutorial failed:" + exc.getMessage());
        }
    }

    public String updateTutorial(Tutorial updatedTutorial, Integer id) throws RuntimeException {
        // search for the tutorial by id, map over the tutorial, alter them, then save
        Tutorial existingTutorial = Tutorial.findById(id).orElse(null);
        if (existingTutorial == null) {
            throw new RuntimeException("Cannot update tutorial for given id:" + id);
        }
        else {
            existingTutorial.setTitle(updatedTutorial.getTitle());
            existingTutorial.setDescription(updatedTutorial.getDescription());
            existingTutorial.setPublished(updatedTutorial.getPublished());
            Tutorial.save(existingTutorial); // save and return edits
            return "Tutorial was updated successfully.";
        }
    }

    public String deleteTutorial(Integer id) throws RuntimeException {
        Tutorial existingTutorial = Tutorial.findById(id).orElse(null);
        if (existingTutorial == null) {
            throw new RuntimeException("No tutorials record exist for given id:" + id);
        }
        else {
            Tutorial.deleteById(id);
            return "Tutorial was deleted successfully.";
        }
    }

    public String deleteAllTutorials() throws RuntimeException {
        try {
            Tutorial.deleteAll();
            return "All Tutorials were deleted successfully.";
        }
        catch (RuntimeException exc) {
            throw new RuntimeException("Delete all tutorials failed:" + exc.getMessage());
        }
    }

}
