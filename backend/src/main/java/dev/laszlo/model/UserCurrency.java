package dev.laszlo.model;

public class UserCurrency {
    private String userId;
    private int gemBalance;
    private int totalEarned;
    private int totalSpent;
    private String lastUpdated;
    private String createdAt;

    // Empty constructor (required for frameworks/reflection)
    public UserCurrency() {}

    // Constructor for creating NEW objects (timestamps set by DB)
    public UserCurrency(String userId, int gemBalance, int totalEarned, int totalSpent) {
        this.userId = userId;
        this.gemBalance = gemBalance;
        this.totalEarned = totalEarned;
        this.totalSpent = totalSpent;
    }

    // Full constructor for reading FROM database (all fields populated)
    public UserCurrency(String userId, int gemBalance, int totalEarned, int totalSpent,
                        String lastUpdated, String createdAt) {
        this.userId = userId;
        this.gemBalance = gemBalance;
        this.totalEarned = totalEarned;
        this.totalSpent = totalSpent;
        this.lastUpdated = lastUpdated;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public int getGemBalance() {
        return gemBalance;
    }

    public void setGemBalance(int gemBalance) {
        this.gemBalance = gemBalance;
    }

    public int getTotalEarned() {
        return totalEarned;
    }

    public void setTotalEarned(int totalEarned) {
        this.totalEarned = totalEarned;
    }

    public int getTotalSpent() {
        return totalSpent;
    }

    public void setTotalSpent(int totalSpent) {
        this.totalSpent = totalSpent;
    }

    public String getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(String lastUpdated) {
        this.lastUpdated = lastUpdated;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }
}