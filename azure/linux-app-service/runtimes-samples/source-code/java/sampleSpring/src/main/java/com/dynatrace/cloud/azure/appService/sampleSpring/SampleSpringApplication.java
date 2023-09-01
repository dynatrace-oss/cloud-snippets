package com.dynatrace.cloud.azure.appService.sampleSpring;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.GetMapping;

@SpringBootApplication
@RestController
public class SampleSpringApplication {

	public static void main(String[] args) {
		SpringApplication.run(SampleSpringApplication.class, args);
	}

	@GetMapping("/")
	public String hello(){
		return "Hello from Dynatrace";
	}

}
