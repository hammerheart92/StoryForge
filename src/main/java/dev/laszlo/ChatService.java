package dev.laszlo;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

/**
 * Handles All communication with Claude's API.
 * <p>
 * Responsibilities:
 * - Build HTTP request with proper headers
 * - Send conversation history to API
 * - Parse response and extract text
 */
public class ChatService {

    private static final Logger logger = LoggerFactory.getLogger(ChatService.class);

    // API configuration
    private static final String API_URL = "https://api.anthropic.com/v1/messages";
    private static final String API_VERSION = "2023-06-01";
    private static final String MODEL = "claude-sonnet-4-20250514";
    private static final int MAX_TOKENS = 1024;

    // Reusable HTTP client
    private final HttpClient client;
    private final String apiKey;

    /**
     * Constructor - sets up the HTTP client.
     */
    public ChatService(String apiKey) {
        this.apiKey = apiKey;
        this.client = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(30))
                .build();
    }

    /**
     * Send conversation to Claude and get response.
     *
     * @param history the full conversation history
     * @return Claude's response text, or null if error
     */
    public String sendMessage(ConversationHistory history) {
        try {
            String requestBody = buildRequestBody(history);
            logger.debug("request body: {}", requestBody);

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(API_URL))
                    .header("Content-Type", "application/json")
                    .header("x-api-key", apiKey)
                    .header("anthropic-version", API_VERSION)
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                    .timeout(Duration.ofSeconds(60))
                    .build();

            HttpResponse<String> response = client.send(request,
                    HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200) {
                return parseResponse(response.body());
            } else {
                logger.error("API error {}: {}", response.statusCode(), response.body());
                return null;
            }

        } catch (Exception e) {
            logger.error("Request failed: {}", e.getMessage());
            return null;
        }
    }

    /**
     * Build JSON request body including system prompt and all messages.
     */
    private String buildRequestBody(ConversationHistory history) {
        JsonObject body = new JsonObject();
        body.addProperty("model", MODEL);
        body.addProperty("max_tokens", MAX_TOKENS);

        // Add system prompt if set
        if (history.getSystemPrompt() != null) {
            body.addProperty("system", history.getSystemPrompt());
        }

        // Add conversation messages
        body.add("messages", history.toJsonArray());

        return new Gson().toJson(body);
    }

    /**
     * Extract the content from Claude's response.
     */
    private String parseResponse(String responseJson) {
        JsonObject json = new Gson().fromJson(responseJson, JsonObject.class);
        JsonArray content = json.getAsJsonArray("content");

        if (content != null && content.size() > 0) {
            JsonObject firstBlock = content.get(0).getAsJsonObject();
            return firstBlock.get("text").getAsString();
        }

        return "no content in response";
    }
}
