package dev.laszlo.dto;

import jakarta.validation.constraints.Size;

/**
 * Request payload for updating an existing story
 * All fields are optional - only non-null values will be updated
 */
public class UpdateStoryRequest {

    @Size(max = 255, message = "Title must be less than 255 characters")
    private String title;

    @Size(max = 2000, message = "Description must be less than 2000 characters")
    private String description;

    private String coverImageUrl;

    private Boolean isPublished;

    // Constructors
    public UpdateStoryRequest() {}

    public UpdateStoryRequest(String title, String description, String coverImageUrl, Boolean isPublished) {
        this.title = title;
        this.description = description;
        this.coverImageUrl = coverImageUrl;
        this.isPublished = isPublished;
    }

    // Getters and setters
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getCoverImageUrl() { return coverImageUrl; }
    public void setCoverImageUrl(String coverImageUrl) { this.coverImageUrl = coverImageUrl; }

    public Boolean getIsPublished() { return isPublished; }
    public void setIsPublished(Boolean isPublished) { this.isPublished = isPublished; }
}
