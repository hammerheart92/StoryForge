package dev.laszlo.dto;

import java.time.LocalDateTime;

public class SaveInfoDTO {
    private String storyId;
    private String characterId;
    private String characterName;
    private int messageCount;
    private LocalDateTime lastPlayed;
    private boolean isCompleted;

    // Constructor
    public SaveInfoDTO(String storyId, String characterId, String characterName,
                       int messageCount, LocalDateTime lastPlayed, boolean isCompleted) {
        this.storyId = storyId;
        this.characterId = characterId;
        this.characterName = characterName;
        this.messageCount = messageCount;
        this.lastPlayed = lastPlayed;
        this.isCompleted = isCompleted;
    }

    // Getters
    public String getStoryId() { return storyId; }
    public String getCharacterId() { return characterId; }
    public String getCharacterName() { return characterName; }
    public int getMessageCount() { return messageCount; }
    public LocalDateTime getLastPlayed() { return lastPlayed; }
    public boolean isCompleted() { return isCompleted; }

    // Setters
    public void setStoryId(String storyId) { this.storyId = storyId; }
    public void setCharacterId(String characterId) { this.characterId = characterId; }
    public void setCharacterName(String characterName) { this.characterName = characterName; }
    public void setMessageCount(int messageCount) { this.messageCount = messageCount; }
    public void setLastPlayed(LocalDateTime lastPlayed) { this.lastPlayed = lastPlayed; }
    public void setCompleted(boolean completed) { isCompleted = completed; }
}