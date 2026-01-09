package dev.laszlo.service;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.util.ArrayList;
import java.util.List;

/**
 * Manages conversation history for multi-turn chats.
 * Claude needs to see All previous messages to maintain context.
 * This class stores them and converts to JSON format for the API.
 *
 * ⭐ SESSION 26: Added JSON serialization for database persistence
 */
public class ConversationHistory {

    // Store messages as a list of JSON objects
    private final List<JsonObject> messages = new ArrayList<>();

    // System prompt (sets Claude's personality/behavior)
    private String systemPrompt;

    // ⭐ SESSION 26: Gson instance for serialization
    private static final Gson gson = new GsonBuilder()
            .setPrettyPrinting()
            .create();

    /**
     * Set the system prompt - tells Claude how to behave.
     * Example: "You are a story-teller who writes atmospheric scenes."
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

    // ═══════════════════════════════════════════════════════════════════════════
    // ⭐ SESSION 26: JSON SERIALIZATION FOR DATABASE PERSISTENCE
    // ═══════════════════════════════════════════════════════════════════════════

    /**
     * Serialize conversation history to JSON string for database storage.
     *
     * @return JSON string containing all messages and system prompt
     */
    public String toJson() {
        JsonObject root = new JsonObject();

        // Add system prompt (may be null)
        if (systemPrompt != null) {
            root.addProperty("systemPrompt", systemPrompt);
        }

        // Add messages array
        JsonArray messagesArray = new JsonArray();
        for (JsonObject msg : messages) {
            messagesArray.add(msg);
        }
        root.add("messages", messagesArray);

        // Add metadata
        root.addProperty("messageCount", messages.size());
        root.addProperty("version", "1.0");  // For future schema changes

        return gson.toJson(root);
    }

    /**
     * Deserialize conversation history from JSON string (database load).
     *
     * @param json JSON string from database
     * @return Reconstructed ConversationHistory object
     * @throws IllegalArgumentException if JSON is invalid
     */
    public static ConversationHistory fromJson(String json) {
        if (json == null || json.trim().isEmpty()) {
            throw new IllegalArgumentException("JSON string cannot be null or empty");
        }

        try {
            ConversationHistory history = new ConversationHistory();
            JsonObject root = JsonParser.parseString(json).getAsJsonObject();

            // Restore system prompt
            if (root.has("systemPrompt") && !root.get("systemPrompt").isJsonNull()) {
                history.setSystemPrompt(root.get("systemPrompt").getAsString());
            }

            // Restore messages
            if (root.has("messages")) {
                JsonArray messagesArray = root.getAsJsonArray("messages");
                for (int i = 0; i < messagesArray.size(); i++) {
                    JsonObject msg = messagesArray.get(i).getAsJsonObject();
                    history.messages.add(msg);
                }
            }

            return history;

        } catch (Exception e) {
            throw new IllegalArgumentException("Failed to parse conversation history JSON: " + e.getMessage(), e);
        }
    }

    /**
     * Create an empty conversation history (convenience method).
     */
    public static ConversationHistory createEmpty() {
        return new ConversationHistory();
    }

    /**
     * Check if this conversation has any messages.
     */
    public boolean isEmpty() {
        return messages.isEmpty();
    }

    /**
     * Get a copy of all messages (for debugging or analysis).
     */
    public List<JsonObject> getMessages() {
        return new ArrayList<>(messages);  // Return copy to prevent modification
    }
}