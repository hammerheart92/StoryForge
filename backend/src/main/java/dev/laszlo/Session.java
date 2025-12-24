package dev.laszlo;

/**
 * Represents a chat session.
 */
public class Session {

    private final int id;
    private final String name;
    private final int messageCount;

    public Session(int id, String name, int messageCount) {
        this.id = id;
        this.name = name;
        this.messageCount = messageCount;
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
}
