# Session 1 Summary: First API Call to Claude

**Date:** December 19, 2024  
**Project:** ScenarioChat  
**Goal:** Set up project and make first successful API call

---

## What We Built

A Java application that:
1. Loads an API key securely from environment variables
2. Sends a message to Claude's API
3. Receives and displays Claude's creative response

---

## Project Structure

```
ScenarioChat/
├── src/
│   └── main/
│       └── java/
│           └── dev/
│               └── laszlo/
│                   └── Main.java    ← Our code lives here
├── pom.xml                          ← Maven dependencies
└── docs/
    └── SESSION_01_SUMMARY.md        ← This file
```

---

## Key Concepts Learned

### 1. Environment Variables (Security)

```java
String apiKey = System.getenv("ANTHROPIC_API_KEY");
```

**Why?** Never put API keys in code. They could end up in Git and get stolen.

**How to set in IntelliJ:**  
Run → Edit Configurations → Environment variables → Add `ANTHROPIC_API_KEY=your-key`

---

### 2. HTTP Request (Builder Pattern)

```java
HttpRequest request = HttpRequest.newBuilder()
        .uri(URI.create(API_URL))                    // Where to send
        .header("Content-Type", "application/json")  // Format
        .header("x-api-key", apiKey)                 // Authentication
        .header("anthropic-version", API_VERSION)    // Required by Anthropic
        .POST(HttpRequest.BodyPublishers.ofString(requestBody))  // What to send
        .timeout(Duration.ofSeconds(60))             // Max wait time
        .build();                                    // Create the object
```

**Builder pattern:** Chain methods to configure, then `.build()` finalizes it.

---

### 3. JSON Request Body (What We Send)

```java
JsonObject body = new JsonObject();
body.addProperty("model", MODEL);
body.addProperty("max_tokens", 1024);

JsonArray messages = new JsonArray();
JsonObject message = new JsonObject();
message.addProperty("role", "user");
message.addProperty("content", userMessage);
messages.add(message);

body.add("messages", messages);
```

**Produces this JSON:**
```json
{
  "model": "claude-sonnet-4-20250514",
  "max_tokens": 1024,
  "messages": [
    { "role": "user", "content": "Your message here" }
  ]
}
```

---

### 4. JSON Response (What We Receive)

**Claude returns:**
```json
{
  "content": [
    { "type": "text", "text": "The actual response..." }
  ]
}
```

**We extract the text:**
```java
JsonObject json = new Gson().fromJson(responseJson, JsonObject.class);
JsonArray content = json.getAsJsonArray("content");

if (content != null && content.size() > 0) {
    JsonObject firstBlock = content.get(0).getAsJsonObject();
    return firstBlock.get("text").getAsString();
}
```

**Safety check:** `content != null && content.size() > 0` prevents crashes if response is malformed.

---

### 5. Try-Catch (Error Handling)

```java
try {
    // Network call that might fail
    HttpResponse<String> response = client.send(request, ...);
} catch (Exception e) {
    // Handle the error gracefully
    logger.error("Request failed: {}", e.getMessage());
}
```

**Why?** Network calls can fail (no internet, server down, timeout). Java forces you to handle this.

---

## Dependencies (pom.xml)

| Library | Purpose |
|---------|---------|
| `gson` | Parse JSON (convert between Java objects and JSON strings) |
| `slf4j-api` + `logback-classic` | Logging (better than System.out.println) |
| `junit-jupiter` | Testing (for later sessions) |

---

## Common Errors & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `ANTHROPIC_API_KEY not set` | Env var missing | Add in Run Configuration |
| `401 Unauthorized` | Bad API key | Check key in Anthropic Console |
| `HttpResponse` type error | Missing `<String>` | Use `HttpResponse<String>` |
| `max-tokens` not working | Wrong character | Use underscore: `max_tokens` |

---

## API Configuration

```java
private static final String API_URL = "https://api.anthropic.com/v1/messages";
private static final String API_VERSION = "2023-06-01";
private static final String MODEL = "claude-sonnet-4-20250514";
```

**Model options:**
- `claude-sonnet-4-20250514` — Fast, good quality (we use this)
- `claude-opus-4-20250514` — Slower, highest quality

---

## First Successful Output 🎉

```
🚀 ScenarioChat starting...
✅ API key loaded successfully
📤 Sending message to Claude...
✅ Response received!
============================================================
🎭 CLAUDE'S SCENARIO:
============================================================
Detective Morrison pushed through the heavy oak door...
============================================================
```

---

## Next Session Preview

**Session 2 will add:**
- Interactive chat loop (you type → Claude responds → repeat)
- Conversation history (Claude remembers what was said)
- System prompt (set Claude's personality)

---

## Quick Reference: The Flow

```
You write message
       ↓
buildRequestBody() → JSON
       ↓
HttpClient.send() → Anthropic API
       ↓
Claude processes
       ↓
JSON response
       ↓
parseResponse() → Extract text
       ↓
Print to console
```

---

*Session 1 completed successfully! ✅*