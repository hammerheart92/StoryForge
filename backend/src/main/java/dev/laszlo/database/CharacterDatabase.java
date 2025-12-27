package dev.laszlo.database;

import dev.laszlo.model.Character;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Manages character data in the SQLite database.
 * Handles creating, reading, and storing characters.
 */
public class CharacterDatabase {

    private static final Logger logger = LoggerFactory.getLogger(CharacterDatabase.class);
    private static final String DB_URL = "jdbc:sqlite:storyforge.db";

    /**
     * Initialize the character system.
     * Creates the table and adds default characters.
     */
    public void initializeCharacterTables() {
        createCharactersTable();
        seedDefaultCharacters();
        logger.info("✅ Character system initialized");
    }

    /**
     * Create the characters table if it doesn't exist.
     */
    private void createCharactersTable() {
        String sql = """
                CREATE TABLE IF NOT EXISTS characters (
                    id TEXT PRIMARY KEY,
                    name TEXT NOT NULL,
                    role TEXT,
                    personality TEXT,
                    speech_style TEXT,
                    avatar_url TEXT,
                    default_mood TEXT,
                    relationship_to_user TEXT,
                    description TEXT
                )
                """;

        try (Connection conn = DriverManager.getConnection(DB_URL);
             Statement stmt = conn.createStatement()) {
            stmt.execute(sql);
            logger.debug("Characters table created/verified");
        } catch (SQLException e) {
            logger.error("❌ Failed to create characters table: {}", e.getMessage());
        }
    }

    /**
     * Add default characters to the database (Narrator and Ilyra).
     * Only adds them if they don't already exist.
     */
    private void seedDefaultCharacters() {
        // Check if characters already exist
        if (getCharacter("narrator") != null) {
            logger.debug("Default characters already exist, skipping seed");
            return;
        }

        // Create Narrator
        Character narrator = new Character(
                "narrator",
                "Narrator",
                "Storyteller",
                Arrays.asList("omniscient", "descriptive", "neutral"),
                "Rich, detailed descriptions. Sets scenes and atmosphere.",
                null,  // No avatar for now
                "observant",
                "guide",
                "The narrator weaves the story, describing scenes, actions, and the world around you."
        );
        saveCharacter(narrator);

        // Create Ilyra
        Character ilyra = new Character(
                "ilyra",
                "Ilyra",
                "Exiled Astronomer",
                Arrays.asList("reserved", "analytical", "emotionally guarded", "curious"),
                "Measured and metaphor-heavy. Uses celestial imagery. Avoids direct answers.",
                null,  // No avatar for now
                "wary",
                "uncertain",
                "Once the court astronomer, Ilyra was exiled after predicting an omen the king refused to believe. She now lives in isolation, studying the stars that betrayed her position but never her passion."
        );
        saveCharacter(ilyra);

        logger.info("📝 Seeded default characters: Narrator and Ilyra");
    }

    /**
     * Save a character to the database.
     */
    private void saveCharacter(Character character) {
        String sql = """
                INSERT OR REPLACE INTO characters 
                (id, name, role, personality, speech_style, avatar_url, 
                 default_mood, relationship_to_user, description)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;

        try (Connection conn = DriverManager.getConnection(DB_URL);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, character.getId());
            pstmt.setString(2, character.getName());
            pstmt.setString(3, character.getRole());
            pstmt.setString(4, String.join(",", character.getPersonality()));
            pstmt.setString(5, character.getSpeechStyle());
            pstmt.setString(6, character.getAvatarUrl());
            pstmt.setString(7, character.getDefaultMood());
            pstmt.setString(8, character.getRelationshipToUser());
            pstmt.setString(9, character.getDescription());

            pstmt.executeUpdate();
            logger.debug("Saved character: {}", character.getName());

        } catch (SQLException e) {
            logger.error("❌ Failed to save character: {}", e.getMessage());
        }
    }

    /**
     * Get a character by ID.
     * Returns null if character doesn't exist.
     */
    public Character getCharacter(String id) {
        String sql = "SELECT * FROM characters WHERE id = ?";

        try (Connection conn = DriverManager.getConnection(DB_URL);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, id);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                Character character = new Character();
                character.setId(rs.getString("id"));
                character.setName(rs.getString("name"));
                character.setRole(rs.getString("role"));

                // Parse personality (stored as comma-separated string)
                String personalityStr = rs.getString("personality");
                character.setPersonality(Arrays.asList(personalityStr.split(",")));

                character.setSpeechStyle(rs.getString("speech_style"));
                character.setAvatarUrl(rs.getString("avatar_url"));
                character.setDefaultMood(rs.getString("default_mood"));
                character.setRelationshipToUser(rs.getString("relationship_to_user"));
                character.setDescription(rs.getString("description"));

                return character;
            }

        } catch (SQLException e) {
            logger.error("❌ Failed to get character {}: {}", id, e.getMessage());
        }

        return null;  // Character not found
    }

    /**
     * Get all available characters.
     */
    public List<Character> getAllCharacters() {
        List<Character> characters = new ArrayList<>();
        String sql = "SELECT * FROM characters ORDER BY id";

        try (Connection conn = DriverManager.getConnection(DB_URL);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Character character = new Character();
                character.setId(rs.getString("id"));
                character.setName(rs.getString("name"));
                character.setRole(rs.getString("role"));

                // Parse personality
                String personalityStr = rs.getString("personality");
                character.setPersonality(Arrays.asList(personalityStr.split(",")));

                character.setSpeechStyle(rs.getString("speech_style"));
                character.setAvatarUrl(rs.getString("avatar_url"));
                character.setDefaultMood(rs.getString("default_mood"));
                character.setRelationshipToUser(rs.getString("relationship_to_user"));
                character.setDescription(rs.getString("description"));

                characters.add(character);
            }

            logger.info("📂 Loaded {} characters", characters.size());

        } catch (SQLException e) {
            logger.error("❌ Failed to get all characters: {}", e.getMessage());
        }

        return characters;
    }
}
