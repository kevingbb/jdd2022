package com.appsdata.api;

import java.util.Arrays;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.retry.annotation.EnableRetry;

import com.appsdata.api.repositories.TutorialRepository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@EnableRetry
@SpringBootApplication
public class BlairApplication {
	private static final Logger logger = LoggerFactory.getLogger(BlairApplication.class);

	public static void main(String[] args) {
		logger.debug("this is a debug message");
		logger.info("this is a info message");
		logger.warn("this is a warn message");
		logger.error("this is a error message");
		SpringApplication.run(BlairApplication.class, args);
	}

	@Bean
	public CommandLineRunner commandLineRunner(ApplicationContext ctx, TutorialRepository repository) {
		return args -> {

			// System.out.println("Let's inspect the beans provided by Spring Boot:");

			// String[] beanNames = ctx.getBeanDefinitionNames();
			// Arrays.sort(beanNames);
			// for (String beanName : beanNames) {
			// 	System.out.println(beanName);
			// }
		};
	}

}
