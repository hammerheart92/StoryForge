package dev.laszlo.dto;

import java.time.LocalDateTime;

/**
 * Response DTO for gallery item (story_content) data
 */
public class GalleryItemDto {

    private Long contentId;
    private String storyId;
    private String contentType;
    private String contentCategory;
    private String title;
    private String description;
    private Integer unlockCost;
    private String rarity;
    private String unlockCondition;
    private String contentUrl;
    private String thumbnailUrl;
    private Integer displayOrder;
    private Long createdByUserId;
    private LocalDateTime createdAt;

    // Constructors
    public GalleryItemDto() {}

    public GalleryItemDto(Long contentId, String storyId, String contentType, String contentCategory,
                          String title, String description, Integer unlockCost, String rarity,
                          String unlockCondition, String contentUrl, String thumbnailUrl,
                          Integer displayOrder, Long createdByUserId, LocalDateTime createdAt) {
        this.contentId = contentId;
        this.storyId = storyId;
        this.contentType = contentType;
        this.contentCategory = contentCategory;
        this.title = title;
        this.description = description;
        this.unlockCost = unlockCost;
        this.rarity = rarity;
        this.unlockCondition = unlockCondition;
        this.contentUrl = contentUrl;
        this.thumbnailUrl = thumbnailUrl;
        this.displayOrder = displayOrder;
        this.createdByUserId = createdByUserId;
        this.createdAt = createdAt;
    }

    // Getters and setters
    public Long getContentId() { return contentId; }
    public void setContentId(Long contentId) { this.contentId = contentId; }

    public String getStoryId() { return storyId; }
    public void setStoryId(String storyId) { this.storyId = storyId; }

    public String getContentType() { return contentType; }
    public void setContentType(String contentType) { this.contentType = contentType; }

    public String getContentCategory() { return contentCategory; }
    public void setContentCategory(String contentCategory) { this.contentCategory = contentCategory; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Integer getUnlockCost() { return unlockCost; }
    public void setUnlockCost(Integer unlockCost) { this.unlockCost = unlockCost; }

    public String getRarity() { return rarity; }
    public void setRarity(String rarity) { this.rarity = rarity; }

    public String getUnlockCondition() { return unlockCondition; }
    public void setUnlockCondition(String unlockCondition) { this.unlockCondition = unlockCondition; }

    public String getContentUrl() { return contentUrl; }
    public void setContentUrl(String contentUrl) { this.contentUrl = contentUrl; }

    public String getThumbnailUrl() { return thumbnailUrl; }
    public void setThumbnailUrl(String thumbnailUrl) { this.thumbnailUrl = thumbnailUrl; }

    public Integer getDisplayOrder() { return displayOrder; }
    public void setDisplayOrder(Integer displayOrder) { this.displayOrder = displayOrder; }

    public Long getCreatedByUserId() { return createdByUserId; }
    public void setCreatedByUserId(Long createdByUserId) { this.createdByUserId = createdByUserId; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
