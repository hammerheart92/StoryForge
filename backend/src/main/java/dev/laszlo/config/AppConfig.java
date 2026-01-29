package dev.laszlo.config;

import dev.laszlo.database.CharacterDatabase;
import dev.laszlo.database.DatabaseService;
import dev.laszlo.service.ChatService;
import dev.laszlo.service.NarrativeEngine;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
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
    @Profile("!test")  // Skip in test profile - let Spring auto-configure H2
    public DataSource dataSource() {
        String databaseUrl = System.getenv("DATABASE_URL");

        // If DATABASE_URL exists (Railway/production), parse it
        if (databaseUrl != null && !databaseUrl.isEmpty()) {
            return createDataSourceFromUrl(databaseUrl);
        }

        // Local development fallback
        org.springframework.jdbc.datasource.DriverManagerDataSource dataSource =
                new org.springframework.jdbc.datasource.DriverManagerDataSource();
        dataSource.setDriverClassName("org.postgresql.Driver");
        dataSource.setUrl("jdbc:postgresql://localhost:5432/storyforge");
        dataSource.setUsername("postgres");
        dataSource.setPassword("postgres");
        return dataSource;
    }

    private DataSource createDataSourceFromUrl(String url) {
        // Convert Railway URL format to JDBC format
        if (!url.startsWith("jdbc:")) {
            url = "jdbc:" + url;
        }

        // Extract credentials from URL (format: jdbc:postgresql://user:password@host:port/database)
        String username = "postgres";
        String password = "";
        String jdbcUrl = url;

        if (url.contains("@")) {
            try {
                String withoutPrefix = url.substring("jdbc:postgresql://".length());
                int atIndex = withoutPrefix.indexOf("@");
                if (atIndex > 0) {
                    String credentials = withoutPrefix.substring(0, atIndex);
                    String hostAndDb = withoutPrefix.substring(atIndex + 1);

                    int colonIndex = credentials.indexOf(":");
                    if (colonIndex > 0) {
                        username = credentials.substring(0, colonIndex);
                        password = credentials.substring(colonIndex + 1);
                    }

                    jdbcUrl = "jdbc:postgresql://" + hostAndDb;
                }
            } catch (Exception e) {
                throw new RuntimeException("Failed to parse DATABASE_URL: " + e.getMessage());
            }
        }

        org.springframework.jdbc.datasource.DriverManagerDataSource dataSource =
                new org.springframework.jdbc.datasource.DriverManagerDataSource();
        dataSource.setDriverClassName("org.postgresql.Driver");
        dataSource.setUrl(jdbcUrl);
        dataSource.setUsername(username);
        dataSource.setPassword(password);
        return dataSource;
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