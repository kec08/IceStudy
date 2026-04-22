package com.icestudy;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class IcestudyApiApplication {

	public static void main(String[] args) {
		SpringApplication.run(IcestudyApiApplication.class, args);
	}

}
