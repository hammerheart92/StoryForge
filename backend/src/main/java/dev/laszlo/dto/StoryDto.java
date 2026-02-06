package dev.laszlo.dto;

import java.time.LocalDateTime;

/**
 * Response DTO for story data
 */
public class StoryDto {

    private Long id;
    private String storyId;
    private String title;
    private String description;
    private String coverImageUrl;
    private boolean isPublished;
    private Long createdByUserId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Constructors
    public StoryDto() {}

    public StoryDto(Long id, String storyId, String title, String description,
                    String coverImageUrl, boolean isPublished, Long createdByUserId,
                    LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.storyId = storyId;
        this.title = title;
        this.description = description;
        this.coverImageUrl = coverImageUrl;
        this.isPublished = isPublished;
        this.createdByUserId = createdByUserId;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getStoryId() { return storyId; }
    public void setStoryId(String storyId) { this.storyId = storyId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getCoverImageUrl() { return coverImageUrl; }
    public void setCoverImageUrl(String coverImageUrl) { this.coverImageUrl = coverImageUrl; }

    public boolean isPublished() { return isPublished; }
    public void setPublished(boolean published) { isPublished = published; }

    public Long getCreatedByUserId() { return createdByUserId; }
    public void setCreatedByUserId(Long createdByUserId) { this.createdByUserId = createdByUserId; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
