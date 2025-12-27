package dev.laszlo.model;

/**
 * Represents a choice that the user can make in the narrative.
 * Each choice leads to a different branch in the story and may switch the active character.
 */
public class Choice {
    private String id;              // Unique identifier (e.g., "choice_1", "ask_about_stars")
    private String label;           // Display text shown to user (e.g., "Ask about the constellation")
    private String nextSpeaker;     // Who responds next (e.g., "ilyra", "narrator")
    private String description;     // Optional tooltip/hover text for additional context

    // Default constructor
    public Choice() {
    }

    // Convenience constructor for basic choices
    public Choice(String id, String label, String nextSpeaker) {
        this.id = id;
        this.label = label;
        this.nextSpeaker = nextSpeaker;
    }

    // Full constructor
    public Choice(String id, String label, String nextSpeaker, String description) {
        this.id = id;
        this.label = label;
        this.nextSpeaker = nextSpeaker;
        this.description = description;
    }

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public String getNextSpeaker() {
        return nextSpeaker;
    }

    public void setNextSpeaker(String nextSpeaker) {
        this.nextSpeaker = nextSpeaker;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    @Override
    public String toString() {
        return "Choice{" +
                "id='" + id + '\'' +
                ", label='" + label + '\'' +
                ", nextSpeaker='" + nextSpeaker + '\'' +
                ", description='" + description + '\'' +
                '}';
    }
}