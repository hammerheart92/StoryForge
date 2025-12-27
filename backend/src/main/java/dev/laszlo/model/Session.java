package dev.laszlo.model;

/**
 * Represents a chat session.
 */
public class Session {

    private final int id;
    private final String name;
    private final int messageCount;
    private final String createdAt;

    public Session(int id, String name, int messageCount, String createdAt) {
        this.id = id;
        this.name = name;
        this.messageCount = messageCount;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public int getMessageCount() {
        return messageCount;
    }

    public String getCreatedAt() {
        return createdAt;
    }
}
