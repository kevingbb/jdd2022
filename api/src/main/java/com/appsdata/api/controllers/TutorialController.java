package com.appsdata.api.controllers;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;


import org.springframework.beans.factory.annotation.Autowired;

import java.lang.Exception;

import com.appsdata.api.entities.Tutorial;
import com.appsdata.api.entities.PagedTutorial;
import com.appsdata.api.exception.ErrorResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
public class TutorialController {
    // Used for Logging
    private static final Logger logger = LoggerFactory.getLogger(TutorialController.class);

    // Property to hold our service
    @Autowired
    private TutorialService service;

    // Get to /tutorials that returns list of people
    @GetMapping("/tutorials")
    public ResponseEntity<PagedTutorial> getTutorials(
      @RequestParam(defaultValue = "") String title,
      @RequestParam(defaultValue = "0") Integer page,
      @RequestParam(defaultValue = "3") Integer size) {
        logger.info("getTutorials.");
        return ResponseEntity.ok(service.getTutorials(title, page, size, "id")); // Returns all tutorials!
    }

    // Get to /tutorials/:id that returns a single person
    @GetMapping("/tutorials/{id}")
    public ResponseEntity<Tutorial> getTutorial(@PathVariable Integer id) {
        logger.info("getTutorial.");
        return ResponseEntity.ok(service.getTutorial(id)); // Returns single tutorial
    }

    // Post to /tutorials, takes in request body which must be of type Tutorial
    @PostMapping("/tutorials")
    public ResponseEntity<String> createTutorial(@RequestBody Tutorial newTutorial){
        logger.info("createTutorial.");
        return ResponseEntity.ok(service.createTutorial(newTutorial)); // returns all tutorials
    }

    // put to /tutorials/:id, takes in the body and url param id
    @PutMapping("/tutorials/{id}")
    public ResponseEntity<String> updateTutorial(@RequestBody Tutorial updatedTutorial, @PathVariable Integer id){
        logger.info("updateTutorial.");
        return ResponseEntity.ok(service.updateTutorial(updatedTutorial, id)); // return all tutorials
    }

    // delete request to /tutorials/:id, deletes person based on id param
    @DeleteMapping("/tutorials/{id}")
    public ResponseEntity<String> deleteTutorial(@PathVariable Integer id){
        logger.info("deleteTutorial.");
        return ResponseEntity.ok(service.deleteTutorial(id)); // delete single tutorial
    }

    // delete request to /tutorials/:id, deletes person based on id param
    @DeleteMapping("/tutorials")
    public ResponseEntity<String> deleteAllTutorials(){
        logger.info("deleteTutorials.");
        return ResponseEntity.ok(service.deleteAllTutorials()); //delete all tutorials
    }

    // Exception Handler method added in TutorialController
    @ExceptionHandler()
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleCustomerAlreadyExistsException(Exception ex)
    {
        logger.error("Tutorial Controller Error:" + ex.getMessage());
        return new ErrorResponse(HttpStatus.BAD_REQUEST.value(), ex.getMessage());
    }

}
