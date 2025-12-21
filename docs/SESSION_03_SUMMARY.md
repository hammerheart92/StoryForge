# Session 3 Summary: REST API with Spring Boot

**Date:** December 21, 2024  
**Project:** ScenarioChat  
**Goal:** Expose chatbot as REST API so any client can connect

---

## What We Built

A REST API server that:
1. Runs on `http://localhost:8080`
2. Accepts HTTP requests from any client
3. Returns JSON responses
4. Maintains conversation history across requests

---

## Architecture Change

**Before (Session 2):**
```
┌─────────────┐
│   Console   │ ←→ ChatService ←→ Claude API
└─────────────┘
```

**After (Session 3):**
```
┌─────────────┐
│ PowerShell  │
├─────────────┤
│   Flutter   │ ←→ REST API (port 8080) ←→ ChatService ←→ Claude API
├─────────────┤
│   Browser   │
└─────────────┘
```

---

## Project Structure (Updated)

```
ScenarioChat/
├── src/
│   └── main/
│       └── java/
│           └── dev/
│               └── laszlo/
│                   ├── Application.java         ← Spring Boot entry point (new)
│                   ├── ChatController.java      ← REST endpoints (new)
│                   ├── ChatService.java         ← API communication
│                   ├── ConversationHistory.java ← Message storage
│                   └── Main.java                ← Console version (Session 2)
├── pom.xml                                      ← Updated with Spring Boot
└── docs/
    ├── SESSION_01_SUMMARY.md
    ├── SESSION_02_SUMMARY.md
    └── SESSION_03_SUMMARY.md   ← This file
```

---

## Key Concepts Learned

### 1. Spring Boot Application Entry Point

```java
@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

**Important distinction:**
- `@SpringBootApplication` — the annotation (configures the app)
- `SpringApplication.run()` — the method that starts the server

Common mistake: Writing `SpringBootApplication.run()` instead of `SpringApplication.run()`

---

### 2. REST Controller Annotations

```java
@RestController              // This class handles REST requests
@RequestMapping("/api/chat") // Base URL path
public class ChatController {

    @GetMapping("/status")   // Handles GET /api/chat/status
    public ResponseEntity<...> getStatus() { }

    @PostMapping("/send")    // Handles POST /api/chat/send
    public ResponseEntity<...> sendMessage(@RequestBody ...) { }
}
```

| Annotation | Purpose |
|------------|---------|
| `@RestController` | Marks class as REST API (returns JSON automatically) |
| `@RequestMapping` | Sets base URL path for all endpoints |
| `@GetMapping` | Handles GET requests |
| `@PostMapping` | Handles POST requests |
| `@RequestBody` | Converts JSON body to Java object |

---

### 3. GET vs POST (Restaurant Analogy)

**GET = "Just looking / asking for info"**
- Like asking: "Is the kitchen open?"
- You're not changing anything

**POST = "I want to DO something"**
- Like saying: "I'd like to order the pasta"
- You're sending data and expecting action

---

### 4. The 3 Endpoints

| Method | URL | Purpose | Restaurant Analogy |
|--------|-----|---------|-------------------|
| GET | `/api/chat/status` | Check if server is running | "Are you open?" |
| POST | `/api/chat/send` | Send message, get response | "I'd like to order" |
| POST | `/api/chat/reset` | Clear conversation history | "Clear my table" |

---

### 5. ResponseEntity (HTTP Status Codes)

```java
ResponseEntity.ok(result)                    // 200 = Success
ResponseEntity.badRequest().body(error)      // 400 = Bad request
ResponseEntity.internalServerError().body()  // 500 = Server error
```

| Code | Meaning | Restaurant |
|------|---------|------------|
| 200 | OK, success | "Here's your food!" |
| 400 | Bad request | "We don't serve that" |
| 500 | Server error | "Kitchen broke down" |

---

### 6. Map as JSON Response (The Plate Analogy)

```java
Map<String, Object> result = new HashMap<>();
result.put("response", "The dragon...");
result.put("messageCount", 2);
return ResponseEntity.ok(result);
```

Think of it as a **plate with labeled compartments**:
```
┌─────────────────────────────────┐
│  "response" → "The dragon..."   │
│  "messageCount" → 2             │
└─────────────────────────────────┘
```

Becomes JSON:
```json
{
  "response": "The dragon...",
  "messageCount": 2
}
```

---

## Questions & Answers from This Session

### Q1: Why wasn't Spring Boot import working?

**Problem:** Missing parent POM in `pom.xml`

**Solution:** Added Spring Boot parent:
```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.2.1</version>
</parent>
```

The parent POM manages all dependency versions automatically.

---

### Q2: "Cannot find symbol: run" error

**Problem:** Wrong class name on line 18
```java
SpringBootApplication.run(...)  // WRONG - this is the annotation
```

**Solution:**
```java
SpringApplication.run(...)  // CORRECT - this is the class with run()
```

---

### Q3: PowerShell curl not working?

**Problem:** PowerShell's `curl` is an alias for `Invoke-WebRequest`, not real curl.

**Solutions:**

Use PowerShell syntax:
```powershell
Invoke-WebRequest -Uri "http://localhost:8080/api/chat/send" -Method POST -ContentType "application/json" -Body '{"message":"Hello"}'
```

Or use real curl:
```powershell
curl.exe -X POST http://localhost:8080/api/chat/send -H "Content-Type: application/json" -d "{\"message\":\"Hello\"}"
```

---

## Maven pom.xml (Final Version)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <!-- Spring Boot Parent - manages versions -->
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.1</version>
    </parent>

    <groupId>dev.laszlo</groupId>
    <artifactId>ScenarioChat</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>jar</packaging>

    <properties>
        <java.version>21</java.version>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <dependencies>
        <!-- Spring Boot Web -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <!-- JSON parsing -->
        <dependency>
            <groupId>com.google.code.gson</groupId>
            <artifactId>gson</artifactId>
            <version>2.10.1</version>
        </dependency>

        <!-- Testing -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

---

## Test Commands (PowerShell)

**Check status:**
```powershell
Invoke-WebRequest -Uri "http://localhost:8080/api/chat/status" -Method GET
```

**Send message:**
```powershell
Invoke-WebRequest -Uri "http://localhost:8080/api/chat/send" -Method POST -ContentType "application/json" -Body '{"message":"A dragon wakes up"}'
```

**Reset conversation:**
```powershell
Invoke-WebRequest -Uri "http://localhost:8080/api/chat/reset" -Method POST
```

---

## Test Results

**Conversation flow tested:**
1. "A dragon wakes up" → messageCount: 2, Claude described emerald eye
2. "What color are its scales?" → messageCount: 4, Claude remembered "deep emerald"
3. Reset → "Conversation reset"

✅ Memory works across HTTP requests!

---

## Files Created This Session

### Application.java
- Spring Boot entry point
- `@SpringBootApplication` annotation
- `SpringApplication.run()` starts embedded Tomcat server

### ChatController.java
- REST endpoints for chat functionality
- Uses `ChatService` and `ConversationHistory` from Session 2
- Returns JSON via `ResponseEntity`

### pom.xml (Updated)
- Added Spring Boot parent
- Added `spring-boot-starter-web`
- Added `spring-boot-starter-test`

---

## Run Configuration

**Name:** Application  
**Main class:** `dev.laszlo.Application`  
**Environment variables:** `ANTHROPIC_API_KEY=your-key`

---

## Next Session Preview

**Session 4 options:**
- Add persistence (save conversations to database)
- Add user sessions (multiple users can chat separately)
- Start Flutter frontend (connect to this API)
- Deploy to cloud (make API accessible from internet)

---

*Session 3 completed successfully! ✅*