package dev.laszlo.model;

import java.util.List;

/**
 * Represents a character in the narrative.
 * Each character has a distinct personality, speaking style, and mood.
 *
 * ⭐ SESSION 21: Added storyId field to support multi-story system
 */
public class Character {

    private String id;                      // "ilyra", "narrator"
    private String name;                    // "Ilyra"
    private String role;                    // "Exiled Astronomer"
    private List<String> personality;       // ["reserved", "analytical"]
    private String speechStyle;             // How they speak
    private String avatarUrl;               // Character image URL
    private String defaultMood;             // "wary", "cheerful"
    private String relationshipToUser;      // "uncertain", "friendly"
    private String description;             // Backstory
    private String storyId;                 // ⭐ NEW: "observatory", "illidan"

    // Empty constructor

    public Character() {
    }

    // Full constructor

    public Character(String id, String name, String role, List<String> personality,
                     String speechStyle, String avatarUrl, String defaultMood,
                     String relationshipToUser, String description, String storyId) {
        this.id = id;
        this.name = name;
        this.role = role;
        this.personality = personality;
        this.speechStyle = speechStyle;
        this.avatarUrl = avatarUrl;
        this.defaultMood = defaultMood;
        this.relationshipToUser = relationshipToUser;
        this.description = description;
        this.storyId = storyId;
    }

    // Getters and Setters

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public List<String> getPersonality() {
        return personality;
    }

    public void setPersonality(List<String> personality) {
        this.personality = personality;
    }

    public String getSpeechStyle() {
        return speechStyle;
    }

    public void setSpeechStyle(String speechStyle) {
        this.speechStyle = speechStyle;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public String getDefaultMood() {
        return defaultMood;
    }

    public void setDefaultMood(String defaultMood) {
        this.defaultMood = defaultMood;
    }

    public String getRelationshipToUser() {
        return relationshipToUser;
    }

    public void setRelationshipToUser(String relationshipToUser) {
        this.relationshipToUser = relationshipToUser;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStoryId() {
        return storyId;
    }

    public void setStoryId(String storyId) {
        this.storyId = storyId;
    }
}
