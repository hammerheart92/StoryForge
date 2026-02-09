package dev.laszlo.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/**
 * Request payload for creating a new gallery item (story_content)
 */
public class CreateGalleryItemRequest {

    @NotBlank(message = "Story ID is required")
    private String storyId;

    @NotBlank(message = "Content type is required")
    private String contentType;

    private String contentCategory;

    @NotBlank(message = "Title is required")
    @Size(max = 255, message = "Title must be less than 255 characters")
    private String title;

    @Size(max = 2000, message = "Description must be less than 2000 characters")
    private String description;

    @NotNull(message = "Unlock cost is required")
    private Integer unlockCost;

    private String rarity;

    private String unlockCondition;

    private String contentUrl;

    private String thumbnailUrl;

    private Integer displayOrder;

    // Constructors
    public CreateGalleryItemRequest() {}

    public CreateGalleryItemRequest(String storyId, String contentType, String contentCategory,
                                    String title, String description, Integer unlockCost,
                                    String rarity, String unlockCondition, String contentUrl,
                                    String thumbnailUrl, Integer displayOrder) {
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
    }

    // Getters and setters
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
}
