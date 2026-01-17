package dev.laszlo.dto;

/**
 * Data Transfer Object for story completion statistics.
 * Used to display completion progress in the Story Endings screen.
 *
 * ⭐ SESSION 34: Created for story completion system.
 */
public class CompletionStats {
    private int totalSaves;           // Total number of save slots used for this story
    private int completedSaves;       // Number of completed playthroughs
    private int endingsDiscovered;    // Number of unique endings discovered
    private int totalEndings;         // Total endings available for this story
    private double completionPercentage; // Percentage of endings discovered

    public CompletionStats() {
    }

    public CompletionStats(int totalSaves, int completedSaves, int endingsDiscovered,
                          int totalEndings, double completionPercentage) {
        this.totalSaves = totalSaves;
        this.completedSaves = completedSaves;
        this.endingsDiscovered = endingsDiscovered;
        this.totalEndings = totalEndings;
        this.completionPercentage = completionPercentage;
    }

    // Getters
    public int getTotalSaves() { return totalSaves; }
    public int getCompletedSaves() { return completedSaves; }
    public int getEndingsDiscovered() { return endingsDiscovered; }
    public int getTotalEndings() { return totalEndings; }
    public double getCompletionPercentage() { return completionPercentage; }

    // Setters
    public void setTotalSaves(int totalSaves) { this.totalSaves = totalSaves; }
    public void setCompletedSaves(int completedSaves) { this.completedSaves = completedSaves; }
    public void setEndingsDiscovered(int endingsDiscovered) { this.endingsDiscovered = endingsDiscovered; }
    public void setTotalEndings(int totalEndings) { this.totalEndings = totalEndings; }
    public void setCompletionPercentage(double completionPercentage) { this.completionPercentage = completionPercentage; }

    // Convenience methods
    public boolean isFullyCompleted() {
        return endingsDiscovered >= totalEndings;
    }

    public boolean hasStarted() {
        return totalSaves > 0;
    }

    public boolean hasCompletedOnce() {
        return completedSaves > 0;
    }

    @Override
    public String toString() {
        return "CompletionStats{" +
                "totalSaves=" + totalSaves +
                ", completedSaves=" + completedSaves +
                ", endingsDiscovered=" + endingsDiscovered + "/" + totalEndings +
                ", completionPercentage=" + completionPercentage + "%" +
                '}';
    }
}
