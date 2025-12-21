package dev.laszlo;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import java.util.ArrayList;
import java.util.List;

/**
 * Manages conversation history for multi-turn chats.
 * Claude needs to see All previous messages to maintain context.
 * This class stores them and converts to JSON format fot the API.
 */
public class ConversationHistory {

    // Store messages as a list of JSON objects
    private final List<JsonObject> messages = new ArrayList<>();

    // System prompt (sets Claude's personality/behavior)
    private String systemPrompt;

    /**
     * Set the system prompt - tells Claude how to behave.
     * Example: "You are a story teller who writes atmospheric scenes."
     */
    public void setSystemPrompt(String prompt) {
        this.systemPrompt = prompt;
    }

    public String getSystemPrompt() {
        return systemPrompt;
    }

    /**
     * Add user message to history.
     */
    public void addUserMessage(String content) {
        JsonObject message = new JsonObject();
        message.addProperty("role", "user");
        message.addProperty("content", content);
        messages.add(message);
    }

    /**
     * Add Claude's response to history.
     */
    public void addAssistantMessage(String content) {
        JsonObject message = new JsonObject();
        message.addProperty("role", "assistant");
        message.addProperty("content", content);
        messages.add(message);
    }

    /**
     * Convert All messages to JsonArray for API request.
     */
    public JsonArray toJsonArray() {
        JsonArray array = new JsonArray();
        for (JsonObject msg : messages) {
            array.add(msg);
        }
        return array;
    }

    /**
     * Get message count (useful for debugging).
     */
    public int getMessageCount() {
        return messages.size();
    }

    /**
     * Clear All messages (start fresh conversation).
     */
    public void clear() {
        messages.clear();
    }
}
