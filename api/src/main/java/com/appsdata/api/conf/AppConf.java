package com.appsdata.api.conf;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;

@Configuration
public class AppConf implements WebMvcConfigurer {

    @Autowired
	private Environment env;

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOrigins(env.getProperty("my.CORS_ALLOWED_ORIGINS"))
                .allowedMethods("GET", "POST", "PUT", "DELETE");
    }
}
