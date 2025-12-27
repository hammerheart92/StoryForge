package dev.laszlo.config;

import dev.laszlo.database.CharacterDatabase;
import dev.laszlo.database.DatabaseService;
import dev.laszlo.service.ChatService;
import dev.laszlo.service.NarrativeEngine;
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

    /**
     * NEW: Character database bean.
     * Spring will create this when the app starts and call initializeCharacterTables().
     */
    @Bean
    public CharacterDatabase characterDatabase() {
        CharacterDatabase db = new CharacterDatabase();
        db.initializeCharacterTables();     // Create table and add Narrator + Ilyra
        return db;
    }

    /**
     * NEW: Narrative engine bean.
     * Spring will inject ChatService and CharacterDatabase automatically.
     */
    @Bean
    public NarrativeEngine narrativeEngine(
            ChatService chatService,
            CharacterDatabase characterDatabase
    ) {
        return new NarrativeEngine(chatService, characterDatabase);
    }
}