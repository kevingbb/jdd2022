package com.appsdata.api.repositories;

import com.appsdata.api.entities.Tutorial;

import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.beans.factory.annotation.Autowired;

@Component
public class DatabaseLoader implements CommandLineRunner {

	@Autowired
	private TutorialRepository tutorialRepository;

	@Override
	public void run(String... strings) throws Exception {
		this.tutorialRepository.save(new Tutorial("Databaseloader", "Populated via CommandLineRunner.", false));
		this.tutorialRepository.save(new Tutorial("One", "One description.", false));
		this.tutorialRepository.save(new Tutorial("Two", "Two description.", false));
		this.tutorialRepository.save(new Tutorial("Three", "Three description.", false));
		this.tutorialRepository.save(new Tutorial("Four", "Four description.", false));
		this.tutorialRepository.save(new Tutorial("Five", "Five description.", false));
		this.tutorialRepository.save(new Tutorial("Six", "Six description.", false));
	}
}
