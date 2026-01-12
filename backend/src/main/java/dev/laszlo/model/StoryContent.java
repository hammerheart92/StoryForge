package dev.laszlo.model;

public class StoryContent {
    private int contentId;
    private String storyId;
    private String contentType;
    private String contentCategory;
    private String title;
    private String description;
    private int unlockCost;
    private String rarity;
    private String unlockCondition;
    private String contentUrl;
    private String thumbnailUrl;
    private int displayOrder;
    private String createdAt;

    public StoryContent() {}

    public StoryContent(int contentId, String storyId, String contentType, String title,
                        String description, int unlockCost, String rarity) {
        this.contentId = contentId;
        this.storyId = storyId;
        this.contentType = contentType;
        this.title = title;
        this.description = description;
        this.unlockCost = unlockCost;
        this.rarity = rarity;
    }

    // Full constructor for reading FROM database (all 13 fields)
    public StoryContent(int contentId, String storyId, String contentType, String contentCategory,
                        String title, String description, int unlockCost, String rarity,
                        String unlockCondition, String contentUrl, String thumbnailUrl,
                        int displayOrder, String createdAt) {
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
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public int getContentId() { return contentId; }
    public void setContentId(int contentId) { this.contentId = contentId; }

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

    public int getUnlockCost() { return unlockCost; }
    public void setUnlockCost(int unlockCost) { this.unlockCost = unlockCost; }

    public String getRarity() { return rarity; }
    public void setRarity(String rarity) { this.rarity = rarity; }

    public String getUnlockCondition() { return unlockCondition; }
    public void setUnlockCondition(String unlockCondition) { this.unlockCondition = unlockCondition; }

    public String getContentUrl() { return contentUrl; }
    public void setContentUrl(String contentUrl) { this.contentUrl = contentUrl; }

    public String getThumbnailUrl() { return thumbnailUrl; }
    public void setThumbnailUrl(String thumbnailUrl) { this.thumbnailUrl = thumbnailUrl; }

    public int getDisplayOrder() { return displayOrder; }
    public void setDisplayOrder(int displayOrder) { this.displayOrder = displayOrder; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}