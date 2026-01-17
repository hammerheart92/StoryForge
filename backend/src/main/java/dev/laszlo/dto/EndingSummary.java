package dev.laszlo.dto;

import java.time.LocalDateTime;

/**
 * Data Transfer Object for story ending information.
 * Used to display discovered/undiscovered endings in the Endings Gallery.
 *
 * ⭐ SESSION 34: Created for story completion system.
 */
public class EndingSummary {
    private String id;              // Ending identifier (e.g., "good_ending", "tragic_ending")
    private String title;           // Display title (hidden if not discovered: "???")
    private String description;     // Ending description (hidden if not discovered)
    private boolean discovered;     // Whether the user has reached this ending
    private LocalDateTime discoveredAt; // When the ending was first discovered (null if not)

    public EndingSummary() {
    }

    public EndingSummary(String id, String title, String description, boolean discovered, LocalDateTime discoveredAt) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.discovered = discovered;
        this.discoveredAt = discoveredAt;
    }

    // Getters
    public String getId() { return id; }
    public String getTitle() { return title; }
    public String getDescription() { return description; }
    public boolean isDiscovered() { return discovered; }
    public LocalDateTime getDiscoveredAt() { return discoveredAt; }

    // Setters
    public void setId(String id) { this.id = id; }
    public void setTitle(String title) { this.title = title; }
    public void setDescription(String description) { this.description = description; }
    public void setDiscovered(boolean discovered) { this.discovered = discovered; }
    public void setDiscoveredAt(LocalDateTime discoveredAt) { this.discoveredAt = discoveredAt; }

    @Override
    public String toString() {
        return "EndingSummary{" +
                "id='" + id + '\'' +
                ", title='" + title + '\'' +
                ", discovered=" + discovered +
                '}';
    }
}
