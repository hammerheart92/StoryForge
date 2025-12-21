# Session 2 Summary: Interactive Chat with Memory

**Date:** December 20, 2024  
**Project:** ScenarioChat  
**Goal:** Build multi-turn conversation with memory and system prompts

---

## What We Built

An interactive chatbot that:
1. Accepts user input in a loop
2. Sends full conversation history to Claude
3. Remembers previous messages (context)
4. Uses a system prompt to set Claude's personality

---

## Project Structure (Updated)

```
ScenarioChat/
├── src/
│   └── main/
│       └── java/
│           └── dev/
│               └── laszlo/
│                   ├── Main.java               ← Interactive loop (updated)
│                   ├── ChatService.java        ← API communication (new)
│                   └── ConversationHistory.java ← Message storage (new)
├── pom.xml
└── docs/
    ├── SESSION_01_SUMMARY.md
    └── SESSION_02_SUMMARY.md   ← This file
```

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                        Main.java                         │
│                   (Interactive loop)                     │
│                          │                               │
│                    User types input                      │
│                          ↓                               │
│  ┌──────────────────────────────────────────────────┐   │
│  │              ConversationHistory                  │   │
│  │  ┌──────────────────────────────────────────┐    │   │
│  │  │ system: "You are a creative storyteller" │    │   │
│  │  │ user: "Tell me about a wizard"           │    │   │
│  │  │ assistant: "The old wizard stood..."     │    │   │
│  │  │ user: "What's his name?"                 │    │   │
│  │  └──────────────────────────────────────────┘    │   │
│  └──────────────────────────────────────────────────┘   │
│                          │                               │
│                          ↓                               │
│  ┌──────────────────────────────────────────────────┐   │
│  │                 ChatService                       │   │
│  │         (Builds request, calls API)              │   │
│  └──────────────────────────────────────────────────┘   │
│                          │                               │
│                          ↓                               │
│                   Anthropic API                          │
└─────────────────────────────────────────────────────────┘
```

**Why separate classes?**
- `Main.java` — Only handles user interaction
- `ChatService.java` — Only handles API calls
- `ConversationHistory.java` — Only manages messages

This is the **Single Responsibility Principle** — each class does one job.

---

## Key Concepts Learned

### 1. ConversationHistory Class

Stores messages as a list and converts to JSON for the API:

```java
private final List<JsonObject> messages = new ArrayList<>();

public void addUserMessage(String content) {
    JsonObject message = new JsonObject();
    message.addProperty("role", "user");
    message.addProperty("content", content);
    messages.add(message);
}

public void addAssistantMessage(String content) {
    JsonObject message = new JsonObject();
    message.addProperty("role", "assistant");
    message.addProperty("content", content);
    messages.add(message);
}
```

**Why both methods?** Claude needs to see WHO said WHAT:
- `"role": "user"` — Your messages
- `"role": "assistant"` — Claude's responses

---

### 2. System Prompt (Personality)

```java
history.setSystemPrompt(
    "You are a creative storyteller who specializes in atmospheric, " +
    "immersive scenarios. You write vivid descriptions and engaging " +
    "dialogue. Keep responses concise but evocative."
);
```

**What it does:** Tells Claude how to behave throughout the conversation.

**In the JSON request:**
```json
{
  "model": "claude-sonnet-4-20250514",
  "system": "You are a creative storyteller...",
  "messages": [...]
}
```

---

### 3. ChatService Class

Handles all API communication:

```java
public ChatService(String apiKey) {
    this.apiKey = apiKey;
    this.client = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(30))
            .build();
}

public String sendMessage(ConversationHistory history) {
    // Build request with full history
    // Send to API
    // Parse and return response
}
```

**Key difference from Session 1:**
- Session 1: Sent single message
- Session 2: Sends entire `ConversationHistory` (all messages)

---

### 4. Interactive Loop

```java
Scanner scanner = new Scanner(System.in);

while (true) {
    System.out.print("You: ");
    String userInput = scanner.nextLine().trim();

    if (userInput.equalsIgnoreCase("quit")) {
        break;
    }

    history.addUserMessage(userInput);
    String response = chatService.sendMessage(history);
    history.addAssistantMessage(response);
    
    System.out.println("Claude: " + response);
}
```

**The flow:**
1. User types message
2. Add to history
3. Send ALL history to Claude
4. Get response
5. Add response to history
6. Print and loop back

---

## Questions & Answers from This Session

### Q1: Why do we use `{}` in logger statements?

```java
logger.error("API error {}: {}", response.statusCode(), response.body());
```

**Answer:** `{}` are SLF4J placeholders — they get replaced with the values that follow, in order.

**Why not use `+` concatenation?**
```java
// Slower - always builds the string:
logger.error("API error " + statusCode + ": " + body);

// Faster - skips string building if logging is disabled:
logger.error("API error {}: {}", statusCode, body);
```

---

### Q2: Why concatenation in setSystemPrompt?

```java
history.setSystemPrompt(
    "You are a creative storyteller who specializes in atmospheric, " +
    "immersive scenarios."
);
```

**Answer:** Purely for readability — keeps lines short so you don't scroll horizontally. Java combines string literals at compile time, so there's no performance cost.

**Alternative in Java 17+:** Text blocks with triple quotes:
```java
history.setSystemPrompt("""
    You are a creative storyteller who specializes in atmospheric, \
    immersive scenarios.
    """);
```

---

### Q3: Why check for null before adding system prompt?

```java
if (history.getSystemPrompt() != null) {
    body.addProperty("system", history.getSystemPrompt());
}
```

**Answer:** This is a **guard clause** — it prevents adding invalid data.

- If system prompt is set → add it to JSON
- If system prompt is null → skip it entirely

Without the check, we'd send `"system": null` which the API might reject.

---

### Q4: Type mismatch error — List<JsonArray> vs List<JsonObject>

**The error:**
```java
private final List<JsonArray> messages = new ArrayList<>();  // WRONG

public void addUserMessage(String content) {
    JsonObject message = new JsonObject();  // Creating JsonObject
    messages.add(message);  // Can't add JsonObject to List<JsonArray>!
}
```

**The fix:**
```java
private final List<JsonObject> messages = new ArrayList<>();  // CORRECT
```

**Lesson:** The list type must match what you're adding to it.

---

## How Memory Works (Debug Output)

First request:
```json
"messages": [
  {"role":"user","content":"A wizard enters a dark cave"}
]
```

Second request (includes previous exchange):
```json
"messages": [
  {"role":"user","content":"A wizard enters a dark cave"},
  {"role":"assistant","content":"The wizard's staff glowed..."},
  {"role":"user","content":"What does he see inside?"}
]
```

**Claude sees the entire conversation** — that's how it maintains context and builds on the story!

---

## Files Created This Session

### ConversationHistory.java
- Stores messages as `List<JsonObject>`
- `addUserMessage()` / `addAssistantMessage()` — add messages with role
- `toJsonArray()` — convert to JSON for API
- `setSystemPrompt()` / `getSystemPrompt()` — manage personality

### ChatService.java
- Constructor creates `HttpClient`
- `sendMessage(ConversationHistory)` — sends full history to API
- `buildRequestBody()` — creates JSON with system prompt + messages
- `parseResponse()` — extracts text from Claude's response

### Main.java (Updated)
- Creates `ChatService` and `ConversationHistory`
- Sets system prompt
- Runs interactive loop with `Scanner`
- Adds messages to history after each exchange

---

## Test Conversation (Wizard & Dragon)

Successfully tested multi-turn conversation:
1. "A wizard enters a dark cave" → Claude described atmospheric scene
2. "What does he see inside?" → Claude added dragon and scrying pools
3. "He casts a light spell" → Claude continued story, dragon got annoyed
4. "What kind of magic powers does the wizard have?" → Claude created detailed backstory

**Result:** Claude maintained context across all messages, proving memory works!

---

## Next Session Preview

**Session 3 will add:**
- REST API with Spring Boot (or simple HTTP server)
- External clients can connect (curl, frontend, etc.)
- Proper error handling and validation

---

*Session 2 completed successfully! ✅*