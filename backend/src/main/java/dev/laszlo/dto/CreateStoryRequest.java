package dev.laszlo.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * Request payload for creating a new story
 * Note: storyId is auto-generated from title
 */
public class CreateStoryRequest {

    @NotBlank(message = "Title is required")
    @Size(max = 255, message = "Title must be less than 255 characters")
    private String title;

    @Size(max = 2000, message = "Description must be less than 2000 characters")
    private String description;

    private String coverImageUrl;

    // Constructors
    public CreateStoryRequest() {}

    public CreateStoryRequest(String title, String description, String coverImageUrl) {
        this.title = title;
        this.description = description;
        this.coverImageUrl = coverImageUrl;
    }

    // Getters and setters
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getCoverImageUrl() { return coverImageUrl; }
    public void setCoverImageUrl(String coverImageUrl) { this.coverImageUrl = coverImageUrl; }
}
