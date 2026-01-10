package dev.laszlo.dto;

import java.time.LocalDateTime;

/**
 * Data Transfer Object for save information.
 * Used by REST API to send save metadata to frontend.
 *
 * ⭐ SESSION 29: Added saveSlot field for multi-slot save system
 */
public class SaveInfoDTO {
    private String storyId;
    private int saveSlot;  // NEW: Save slot number (1-5)
    private String characterId;
    private String characterName;
    private int messageCount;
    private LocalDateTime lastPlayed;
    private boolean isCompleted;

    /**
     * NEW: Constructor with saveSlot (7 parameters).
     * Used by new slot-aware endpoints.
     */
    public SaveInfoDTO(String storyId, int saveSlot, String characterId, String characterName,
                       int messageCount, LocalDateTime lastPlayed, boolean isCompleted) {
        this.storyId = storyId;
        this.saveSlot = saveSlot;
        this.characterId = characterId;
        this.characterName = characterName;
        this.messageCount = messageCount;
        this.lastPlayed = lastPlayed;
        this.isCompleted = isCompleted;
    }

    /**
     * OLD: Constructor without saveSlot (6 parameters).
     * Defaults to slot 1 for backward compatibility.
     */
    public SaveInfoDTO(String storyId, String characterId, String characterName,
                       int messageCount, LocalDateTime lastPlayed, boolean isCompleted) {
        this(storyId, 1, characterId, characterName, messageCount, lastPlayed, isCompleted);
    }

    // Getters
    public String getStoryId() { return storyId; }
    public int getSaveSlot() { return saveSlot; }
    public String getCharacterId() { return characterId; }
    public String getCharacterName() { return characterName; }
    public int getMessageCount() { return messageCount; }
    public LocalDateTime getLastPlayed() { return lastPlayed; }
    public boolean isCompleted() { return isCompleted; }

    // Setters
    public void setStoryId(String storyId) { this.storyId = storyId; }
    public void setSaveSlot(int saveSlot) { this.saveSlot = saveSlot; }
    public void setCharacterId(String characterId) { this.characterId = characterId; }
    public void setCharacterName(String characterName) { this.characterName = characterName; }
    public void setMessageCount(int messageCount) { this.messageCount = messageCount; }
    public void setLastPlayed(LocalDateTime lastPlayed) { this.lastPlayed = lastPlayed; }
    public void setCompleted(boolean completed) { isCompleted = completed; }
}