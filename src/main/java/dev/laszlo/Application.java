package dev.laszlo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Spring Boot Applications Entry Point
 *
 * @SpringBootAplication does 3 things:
 * - Enables auto-configuration
 * - Enables component scanning (fins our @RestController)
 * - Marks this as a configuration class
 */
@SpringBootApplication
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
