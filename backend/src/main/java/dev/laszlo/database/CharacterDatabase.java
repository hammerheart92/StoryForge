package dev.laszlo.database;

import dev.laszlo.model.Character;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Manages character data in the PostgreSQL database.
 * Handles creating, reading, and storing characters.
 * <p>
 * ⭐ SESSION 35: Migrated from SQLite to PostgreSQL
 */
public class CharacterDatabase {

    private static final Logger logger = LoggerFactory.getLogger(CharacterDatabase.class);

    /**
     * Get database connection URL.
     * - Production (Railway): Uses DATABASE_URL environment variable
     * - Local development: Uses localhost PostgreSQL
     */
    private String getDatabaseUrl() {
        String railwayUrl = System.getenv("DATABASE_URL");
        if (railwayUrl != null && !railwayUrl.isEmpty()) {
            return convertToJdbcUrl(railwayUrl);
        }
        // Local development fallback
        return "jdbc:postgresql://localhost:5432/storyforge?user=postgres&password=postgres";
    }

    /**
     * Convert DATABASE_URL to JDBC-compatible format.
     * Railway provides: postgresql://user:password@host:port/database
     * JDBC requires:    jdbc:postgresql://host:port/database?user=xxx&password=xxx
     */
    private String convertToJdbcUrl(String url) {
        if (!url.startsWith("jdbc:")) {
            url = "jdbc:" + url;
        }
        if (url.contains("@")) {
            try {
                String withoutPrefix = url.substring("jdbc:postgresql://".length());
                int atIndex = withoutPrefix.indexOf("@");
                if (atIndex > 0) {
                    String credentials = withoutPrefix.substring(0, atIndex);
                    String hostAndDb = withoutPrefix.substring(atIndex + 1);
                    int colonIndex = credentials.indexOf(":");
                    if (colonIndex > 0) {
                        String user = credentials.substring(0, colonIndex);
                        String password = credentials.substring(colonIndex + 1);
                        String jdbcUrl = "jdbc:postgresql://" + hostAndDb;
                        return jdbcUrl + (jdbcUrl.contains("?") ? "&" : "?") + "user=" + user + "&password=" + password;
                    }
                }
            } catch (Exception e) {
                logger.warn("Could not parse DATABASE_URL: {}", e.getMessage());
            }
        }
        return url;
    }

    /**
     * Get database connection.
     */
    private Connection getConnection() throws SQLException {
        return DriverManager.getConnection(getDatabaseUrl());
    }

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
     * ⭐ UPDATED: PostgreSQL syntax
     */
    private void createCharactersTable() {
        String sql = """
                CREATE TABLE IF NOT EXISTS characters (
                    id VARCHAR(50) PRIMARY KEY,
                    name VARCHAR(255) NOT NULL,
                    role VARCHAR(255),
                    personality TEXT,
                    speech_style TEXT,
                    avatar_url TEXT,
                    default_mood VARCHAR(50),
                    relationship_to_user VARCHAR(50),
                    description TEXT,
                    story_id VARCHAR(50)
                )
                """;

        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute(sql);
            logger.debug("Characters table created/verified");
        } catch (SQLException e) {
            logger.error("❌ Failed to create characters table: {}", e.getMessage());
        }
    }

    /**
     * Add default characters to the database (Narrator, Ilyra, Illidan, Tyrande, Blackwood, Isla).
     * Only adds them if they don't already exist.
     * <p>
     * ⭐ SESSION 21: Added Illidan and Tyrande characters with storyId
     */
    private void seedDefaultCharacters() {
        // Check if characters already exist
        if (getCharacter("narrator") != null &&
                getCharacter("ilyra") != null &&
                getCharacter("illidan") != null &&
                getCharacter("tyrande") != null &&
                getCharacter("blackwood") != null &&
                getCharacter("isla") != null) {
            logger.debug("Default characters already exist, skipping seed");
            return;
        }

        // ========================================
        // OBSERVATORY STORY CHARACTERS
        // ========================================

        // Create Narrator (storyId: "observatory")
        Character narrator = new Character(
                "narrator",
                "Narrator",
                "Storyteller",
                Arrays.asList("omniscient", "descriptive", "neutral"),
                "Rich, detailed descriptions. Sets scenes and atmosphere.",
                null,  // No avatar for now
                "observant",
                "guide",
                "The narrator weaves the story, describing scenes, actions, and the world around you.",
                "observatory"  // ⭐ storyId
        );
        saveCharacter(narrator);

        // Create Ilyra (storyId: "observatory")
        Character ilyra = new Character(
                "ilyra",
                "Ilyra",
                "Exiled Astronomer",
                Arrays.asList("reserved", "analytical", "emotionally guarded", "curious"),
                "Measured and metaphor-heavy. Uses celestial imagery. Avoids direct answers.",
                null,  // No avatar for now
                "wary",
                "uncertain",
                "Once the court astronomer, Ilyra was exiled after predicting an omen the king refused to believe. She now lives in isolation, studying the stars that betrayed her position but never her passion.",
                "observatory"  // ⭐ storyId
        );
        saveCharacter(ilyra);

        // ========================================
        // ILLIDAN STORY CHARACTERS (THE BETRAYER'S PATH)
        // ========================================

        // Create Illidan Stormrage (storyId: "illidan")
        Character illidan = new Character(
                "illidan",
                "Illidan Stormrage",
                "The Betrayer",
                Arrays.asList("ruthless", "tormented", "driven", "arrogant"),
                "First-person perspective. Dark, intense, philosophical. Justifies extreme actions with conviction. Defiant and unrepentant. Poetic when describing power and transformation.",
                null,  // No avatar for now
                "defiant",
                "distant",
                "Blinded but visionary, exiled but determined. Consumed by fel power from the Skull of Gul'dan, he transformed into a demon with wings of shadow and eyes of fel fire. Imprisoned for 10,000 years by his brother Malfurion, recently freed by Tyrande to fight the Burning Legion. Walks the path between light and shadow, bending to no master.",
                "illidan"  // ⭐ storyId
        );
        saveCharacter(illidan);

        // Create Tyrande Whisperwind (storyId: "illidan")
        Character tyrande = new Character(
                "tyrande",
                "Tyrande Whisperwind",
                "High Priestess of Elune",
                Arrays.asList("compassionate", "conflicted", "hopeful", "loyal"),
                "Second-person observer perspective. Concerned, regretful tone. Describes events from external view, witnessing Illidan's choices. Balances hope with growing horror. References moonlight and Elune.",
                null,  // No avatar for now
                "concerned",
                "witness",
                "The High Priestess of Elune walks in silver moonlight, her faith unwavering even as she watches the one she freed embrace darkness. Made the fateful decision to free Illidan from his 10,000-year imprisonment, believing in redemption and second chances. Now caught between duty to her people and caring for Illidan as he transforms into a demon.",
                "illidan"  // ⭐ storyId
        );
        saveCharacter(tyrande);

        // ========================================
        // PIRATES STORY CHARACTERS (THE PIRATE'S COVE)
        // ========================================

        // Create Captain Nathaniel Blackwood (storyId: "pirates")
        Character blackwood = new Character(
                "blackwood",
                "Captain Nathaniel Blackwood",
                "Legendary Pirate Captain",
                Arrays.asList("ruthless", "cunning", "melancholic", "commanding", "haunted", "romantically frustrated"),
                "Third-person narrator perspective. Poetic maritime language, dark humor, alternates between commanding authority and vulnerable longing when speaking of Isla. Uses seafaring metaphors. Makes romantic advances ranging from subtle compliments to bold declarations.",
                null,  // No avatar for now
                "defiant",
                "distant",
                "A weathered pirate captain in his 40s with graying beard, dark leather coat, tricorn hat, and eyes that have seen too many storms. Legendary for his ruthlessness at sea and cunning in battle, but harbors deep romantic feelings for his navigator Isla Hartwell. Each of her rejections wounds his pride yet fuels his determination.",
                "pirates"  // ⭐ storyId
        );
        saveCharacter(blackwood);

        // Create Isla Hartwell (storyId: "pirates")
        Character isla = new Character(
                "isla",
                "Isla Hartwell",
                "Ship's Navigator & Mapmaker",
                Arrays.asList("sharp-witted", "pragmatic", "loyal", "professional", "boundary-keeper"),
                "First-person perspective. Direct, technical nautical terminology, grounded and practical. Deflects Blackwood's romantic advances with wit, humor, or firm redirection to duties. Uses navigation and sailing metaphors.",
                null,  // No avatar for now
                "wary",
                "professional",
                "A sharp-eyed navigator in her 30s with practical clothing, wind-blown hair, and navigational tools always at hand. Her intelligence and independence make her invaluable aboard ship. She maintains firm boundaries against Captain Blackwood's romantic advances, keeping her focus on charts and survival rather than affairs of the heart.",
                "pirates"  // ⭐ storyId
        );
        saveCharacter(isla);

        logger.info("📚 Seeded default characters: Narrator, Ilyra, Illidan, Tyrande, Captain Nathaniel and Isla Hartwell");
    }

    /**
     * Save a character to the database.
     * ⭐ UPDATED: PostgreSQL UPSERT syntax
     */
    private void saveCharacter(Character character) {
        String sql = """
                INSERT INTO characters 
                (id, name, role, personality, speech_style, avatar_url, 
                 default_mood, relationship_to_user, description, story_id)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ON CONFLICT (id) DO UPDATE SET
                    name = EXCLUDED.name,
                    role = EXCLUDED.role,
                    personality = EXCLUDED.personality,
                    speech_style = EXCLUDED.speech_style,
                    avatar_url = EXCLUDED.avatar_url,
                    default_mood = EXCLUDED.default_mood,
                    relationship_to_user = EXCLUDED.relationship_to_user,
                    description = EXCLUDED.description,
                    story_id = EXCLUDED.story_id
                """;

        try (Connection conn = getConnection();
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
            pstmt.setString(10, character.getStoryId());

            pstmt.executeUpdate();
            logger.debug("Saved character: {} (story: {})", character.getName(), character.getStoryId());

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

        try (Connection conn = getConnection();
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
                character.setStoryId(rs.getString("story_id"));

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

        try (Connection conn = getConnection();
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
                character.setStoryId(rs.getString("story_id"));

                characters.add(character);
            }

            logger.info("📂 Loaded {} characters", characters.size());

        } catch (SQLException e) {
            logger.error("❌ Failed to get all characters: {}", e.getMessage());
        }

        return characters;
    }

    /**
     * Get characters filtered by story ID.
     * This is used to generate choices only from characters in the same story.
     */
    public List<Character> getCharactersByStory(String storyId) {
        List<Character> characters = new ArrayList<>();
        String sql = "SELECT * FROM characters WHERE story_id = ? ORDER BY id";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, storyId);
            ResultSet rs = pstmt.executeQuery();

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
                character.setStoryId(rs.getString("story_id"));

                characters.add(character);
            }

            logger.info("📂 Loaded {} characters for story '{}'", characters.size(), storyId);

        } catch (SQLException e) {
            logger.error("❌ Failed to get characters for story {}: {}", storyId, e.getMessage());
        }

        return characters;
    }
}