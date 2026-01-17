package dev.laszlo.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Represents a complete narrative response including dialogue and available choices.
 * This is what the API returns to the frontend.
 *
 * ⭐ SESSION 34: Added isEnding and endingId for story completion detection.
 */
public class NarrativeResponse {
    private String dialogue;            // The character's response text
    private String speaker;             // Character ID (e.g., "ilyra", "narrator")
    private String speakerName;         // Display name (e.g., "Ilyra", "Narrator")
    private String mood;                // Current mood (e.g., "wary", "cheerful", "observant")
    private String avatarUrl;           // URL to character avatar image (optional)
    private String actionText;          // Action/gesture description (NEW for Phase 2.3)
    private List<Choice> choices;       // Available choices for the user
    private boolean isEnding = false;   // ⭐ SESSION 34: True if story has ended
    private String endingId;            // ⭐ SESSION 34: Ending identifier (e.g., "good_ending")

    // Default constructor
    public NarrativeResponse() {
        this.choices = new ArrayList<>();
    }

    // Constructor with essential fields
    public NarrativeResponse(String dialogue, String speaker, String speakerName, String mood) {
        this.dialogue = dialogue;
        this.speaker = speaker;
        this.speakerName = speakerName;
        this.mood = mood;
        // REMOVED: this.actionText = getActionText();
        // actionText will be set separately via setActionText()
        this.choices = new ArrayList<>();
    }

    // Getters and Setters
    public String getDialogue() {
        return dialogue;
    }

    public void setDialogue(String dialogue) {
        this.dialogue = dialogue;
    }

    public String getSpeaker() {
        return speaker;
    }

    public void setSpeaker(String speaker) {
        this.speaker = speaker;
    }

    public String getSpeakerName() {
        return speakerName;
    }

    public void setSpeakerName(String speakerName) {
        this.speakerName = speakerName;
    }

    public String getMood() {
        return mood;
    }

    public void setMood(String mood) {
        this.mood = mood;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public List<Choice> getChoices() {
        return choices;
    }

    public void setChoices(List<Choice> choices) {
        this.choices = choices;
    }

    public String getActionText() {
        return actionText;
    }

    public void setActionText(String actionText) {
        this.actionText = actionText;
    }

    // ⭐ SESSION 34: Ending detection getters/setters
    public boolean isEnding() {
        return isEnding;
    }

    public void setEnding(boolean ending) {
        isEnding = ending;
    }

    public String getEndingId() {
        return endingId;
    }

    public void setEndingId(String endingId) {
        this.endingId = endingId;
    }

    // Convenience method to add a single choice
    public void addChoice(Choice choice) {
        this.choices.add(choice);
    }

    @Override
    public String toString() {
        return "NarrativeResponse{" +
                "speaker='" + speakerName + '\'' +
                ", mood='" + mood + '\'' +
                ", choiceCount=" + (choices != null ? choices.size() : 0) +
                ", dialogueLength=" + (dialogue != null ? dialogue.length() : 0) +
                ", actionTextLength=" + (actionText != null ? actionText.length() : 0) +
                ", isEnding=" + isEnding +
                ", endingId='" + endingId + '\'' +
                '}';
    }
}