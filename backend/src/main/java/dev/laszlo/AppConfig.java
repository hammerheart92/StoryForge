package dev.laszlo;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AppConfig {

    @Bean
    public ChatService chatService() {
        String apiKey = System.getenv("ANTHROPIC_API_KEY");
        if (apiKey == null || apiKey.isBlank()) {
            throw new RuntimeException("ANTHROPIC_API_KEY not set!");
        }
        return new ChatService(apiKey);
    }

    @Bean
    public DatabaseService databaseService() {
        return new DatabaseService();
    }
}