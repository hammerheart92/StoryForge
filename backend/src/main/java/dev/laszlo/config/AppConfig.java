package dev.laszlo.config;

import dev.laszlo.database.CharacterDatabase;
import dev.laszlo.database.DatabaseService;
import dev.laszlo.service.ChatService;
import dev.laszlo.service.NarrativeEngine;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;

import javax.sql.DataSource;

@Configuration
public class AppConfig {

    @Autowired
    private Environment environment;  // ⭐ ADD THIS

    @Bean
    public ChatService chatService() {
        String apiKey = System.getenv("ANTHROPIC_API_KEY");

        // ⭐ SESSION 26: Allow test profile to use dummy key
        if (apiKey == null || apiKey.isBlank()) {
            // Check if running in test profile
            boolean isTestProfile = java.util.Arrays.asList(environment.getActiveProfiles()).contains("test");

            if (isTestProfile) {
                apiKey = "test_api_key";  // Dummy key for tests
            } else {
                throw new RuntimeException("ANTHROPIC_API_KEY not set!");
            }
        }

        return new ChatService(apiKey);
    }

    @Bean
    public DatabaseService databaseService(DataSource dataSource) {
        return new DatabaseService(dataSource);
    }

    @Bean
    public CharacterDatabase characterDatabase() {
        CharacterDatabase db = new CharacterDatabase();
        db.initializeCharacterTables();
        return db;
    }

    @Bean
    public NarrativeEngine narrativeEngine(
            ChatService chatService,
            CharacterDatabase characterDatabase
    ) {
        return new NarrativeEngine(chatService, characterDatabase);
    }
}