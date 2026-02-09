package dev.laszlo.dto;

import jakarta.validation.constraints.Size;

/**
 * Request payload for updating an existing gallery item (story_content)
 * All fields are optional - only non-null values will be updated
 */
public class UpdateGalleryItemRequest {

    private String contentType;

    private String contentCategory;

    @Size(max = 255, message = "Title must be less than 255 characters")
    private String title;

    @Size(max = 2000, message = "Description must be less than 2000 characters")
    private String description;

    private Integer unlockCost;

    private String rarity;

    private String unlockCondition;

    private String contentUrl;

    private String thumbnailUrl;

    private Integer displayOrder;

    // Constructors
    public UpdateGalleryItemRequest() {}

    // Getters and setters
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
}
