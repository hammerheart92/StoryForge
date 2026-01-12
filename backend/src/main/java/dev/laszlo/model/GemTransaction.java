package dev.laszlo.model;

public class GemTransaction {
    private int transactionId;
    private String userId;
    private int amount;
    private String transactionType;
    private String source;
    private String storyId;
    private Integer contentId;
    private String timestamp;

    public GemTransaction() {}

    public GemTransaction(String userId, int amount, String transactionType, String source, String storyId) {
        this.userId = userId;
        this.amount = amount;
        this.transactionType = transactionType;
        this.source = source;
        this.storyId = storyId;
    }

    // Full constructor for reading FROM database (all 8 fields)
    public GemTransaction(int transactionId, String userId, int amount, String transactionType,
                          String source, String storyId, Integer contentId, String timestamp) {
        this.transactionId = transactionId;
        this.userId = userId;
        this.amount = amount;
        this.transactionType = transactionType;
        this.source = source;
        this.storyId = storyId;
        this.contentId = contentId;
        this.timestamp = timestamp;
    }

    // Getters and Setters
    public int getTransactionId() { return transactionId; }
    public void setTransactionId(int transactionId) { this.transactionId = transactionId; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public int getAmount() { return amount; }
    public void setAmount(int amount) { this.amount = amount; }

    public String getTransactionType() { return transactionType; }
    public void setTransactionType(String transactionType) { this.transactionType = transactionType; }

    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }

    public String getStoryId() { return storyId; }
    public void setStoryId(String storyId) { this.storyId = storyId; }

    public Integer getContentId() { return contentId; }
    public void setContentId(Integer contentId) { this.contentId = contentId; }

    public String getTimestamp() { return timestamp; }
    public void setTimestamp(String timestamp) { this.timestamp = timestamp; }
}