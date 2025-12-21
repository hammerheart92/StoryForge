package dev.laszlo;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Scanner;

/**
 * ScenarioChat - Interactive AI Chatbot
 * Session 2: Multi-turn conversation
 */
public class Main {

    private static final Logger logger = LoggerFactory.getLogger(Main.class);

    public static void main(String[] args) {
        logger.info("\uD83D\uDE80 Scenario chat starting...");

        // Step 1: Load API key
        String apiKey = System.getenv("ANTHROPIC_API_KEY");
        if (apiKey == null || apiKey.isBlank()) {
            logger.error("ANTHROPIC_API_KEY not set!");
            return;
        }
        logger.info("API key loaded");

        // Step 2: Create our services
        ChatService chatService = new ChatService(apiKey);
        ConversationHistory history = new ConversationHistory();

        // Step 3: Set Claude's personality
        history.setSystemPrompt(
                "You are a creative storyteller who specializes in atmospheric, " +
                        "immersive scenarios. You write vivid descriptions and engaging " +
                        "dialogue. Keep responses concise but evocative."
        );

        // Step 4: Interactive chat loop
        Scanner scanner = new Scanner(System.in);

        System.out.println("\n" + "=".repeat(60));
        System.out.println("\uD83C\uDFAD SCENARIO CHAT - Type 'quit' to exit");
        System.out.println("=".repeat(60) + "\n");

        while (true) {
            // Get user input
            System.out.println("You: ");
            String userInput = scanner.nextLine().trim();

            // Check for exit command
            if (userInput.equalsIgnoreCase("quit") ||
                userInput.equalsIgnoreCase("exit")) {
                System.out.println("\n👋 Goodbye! Chat ended.");
                break;
            }

            // Skip empty input
            if (userInput.isEmpty()) {
                continue;
            }

            // Add user message to history
            history.addUserMessage(userInput);

            // Send to Claude and get response
            System.out.println("\n⏳ Claude is thinking...\n");
            String response = chatService.sendMessage(history);

            if (response != null) {
                // Add Claude's response to history (for memory)
                history.addAssistantMessage(response);

                // Display response
                System.out.println("Claude: " + response);
                System.out.println();
            } else {
                System.out.println("❌ Error getting response. Try again.\\n");
                // Remove the failed user message from history
                history.clear();
            }
        }

        scanner.close();
    }

}
