package dev.laszlo.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * ⭐ SESSION 45: Request payload for conversational narrative interaction.
 * Replaces the old Map-based request with validated DTO.
 */
public class ConversationalRequest {

    @NotBlank(message = "User message is required")
    @Size(max = 500, message = "Message must be under 500 characters")
    private String userMessage;

    @NotBlank(message = "Story ID is required")
    private String storyId;

    @Min(value = 1, message = "Save slot must be 1-5")
    @Max(value = 5, message = "Save slot must be 1-5")
    private int saveSlot = 1;

    public ConversationalRequest() {}

    public ConversationalRequest(String userMessage, String storyId, int saveSlot) {
        this.userMessage = userMessage;
        this.storyId = storyId;
        this.saveSlot = saveSlot;
    }

    public String getUserMessage() { return userMessage; }
    public void setUserMessage(String userMessage) { this.userMessage = userMessage; }

    public String getStoryId() { return storyId; }
    public void setStoryId(String storyId) { this.storyId = storyId; }

    public int getSaveSlot() { return saveSlot; }
    public void setSaveSlot(int saveSlot) { this.saveSlot = saveSlot; }
}
