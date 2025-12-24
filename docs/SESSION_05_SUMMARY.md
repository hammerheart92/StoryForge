# Session 5 Summary: Database Persistence

**Date:** December 24, 2024  
**Project:** StoryForge  
**Goal:** Save conversations to SQLite so chat history survives server restarts

---

## What We Built

A persistence layer that:
1. Creates SQLite database automatically on startup
2. Saves every message (user + assistant) to database
3. Loads previous messages when server restarts
4. Clears database when user resets conversation

---

## Before vs After

**Before (Session 1-4):**
```
You chat → Messages stored in RAM → Server restarts → ❌ Everything lost
```

**After (Session 5):**
```
You chat → Messages saved to SQLite → Server restarts → ✅ History restored
```

---

## What is SQLite?

SQLite is a **file-based database** — your entire database is a single file.

```
StoryForge/
├── backend/
│   ├── storyforge.db    ← Your database (auto-created)
│   └── src/
```

**Unlike MySQL/PostgreSQL:** No separate server needed, just a file.

**Used by:** Android apps, iOS apps, browsers, desktop apps — perfect for learning!

---

## Database Table Structure

**Table: `messages`**

| Column | Type | Purpose |
|--------|------|---------|
| id | INTEGER | Auto-generated unique ID (1, 2, 3...) |
| role | TEXT | "user" or "assistant" |
| content | TEXT | The message text |
| timestamp | TEXT | When message was sent |

---

## Project Structure (Updated)

```
StoryForge/
├── backend/
│   ├── src/main/java/dev/laszlo/
│   │   ├── Application.java
│   │   ├── ChatController.java      ← Modified (uses DatabaseService)
│   │   ├── ChatService.java
│   │   ├── ConversationHistory.java
│   │   ├── DatabaseService.java     ← NEW
│   │   └── Main.java
│   ├── pom.xml                      ← Added SQLite dependency
│   └── storyforge.db                ← Auto-created database file
├── frontend/
├── prompts/
└── docs/
```

---

## Key Concepts Learned

### 1. Maven Dependency for SQLite

**pom.xml:**
```xml
<dependency>
    <groupId>org.xerial</groupId>
    <artifactId>sqlite-jdbc</artifactId>
    <version>3.44.1.0</version>
</dependency>
```

---

### 2. Database Connection

```java
private static final String DB_URL = "jdbc:sqlite:storyforge.db";

Connection conn = DriverManager.getConnection(DB_URL);
```

| Part | Meaning |
|------|---------|
| `jdbc:` | Java Database Connectivity protocol |
| `sqlite:` | Using SQLite driver |
| `storyforge.db` | Database filename (created if doesn't exist) |

---

### 3. Try-With-Resources (Auto-close)

```java
try (Connection conn = DriverManager.getConnection(DB_URL);
     Statement stmt = conn.createStatement()) {
    
    // Use connection here
    
} // Connection automatically closed here!
```

**Why?** Database connections are limited resources. Always close them!

---

### 4. Creating Tables (DDL)

```java
String createTableSQL = """
    CREATE TABLE IF NOT EXISTS messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        role TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL
    )
    """;

stmt.execute(createTableSQL);
```

| SQL | Meaning |
|-----|---------|
| `CREATE TABLE IF NOT EXISTS` | Only create if table doesn't exist |
| `PRIMARY KEY AUTOINCREMENT` | Auto-generate unique IDs |
| `NOT NULL` | Field is required |

---

### 5. Inserting Data (Safe Way)

```java
String insertSQL = "INSERT INTO messages (role, content, timestamp) VALUES (?, ?, ?)";

PreparedStatement pstmt = conn.prepareStatement(insertSQL);
pstmt.setString(1, role);      // First ?
pstmt.setString(2, content);   // Second ?
pstmt.setString(3, timestamp); // Third ?
pstmt.executeUpdate();
```

**Why `?` placeholders?** Prevents SQL injection attacks!

```java
// ❌ DANGEROUS - user could inject malicious SQL
String sql = "INSERT INTO messages VALUES ('" + userInput + "')";

// ✅ SAFE - PreparedStatement escapes special characters
pstmt.setString(1, userInput);
```

---

### 6. Querying Data (SELECT)

```java
String selectSQL = "SELECT role, content FROM messages ORDER BY id ASC";

ResultSet rs = stmt.executeQuery(selectSQL);

while (rs.next()) {
    String role = rs.getString("role");
    String content = rs.getString("content");
}
```

**Think of ResultSet like a cursor:**
```
rs.next() → Row 1: | "user"      | "Hello"     |
rs.next() → Row 2: | "assistant" | "Hi there!" |
rs.next() → false (no more rows)
```

---

### 7. Deleting Data

```java
String deleteSQL = "DELETE FROM messages";
stmt.executeUpdate(deleteSQL);
```

---

## DatabaseService.java (Complete)

```java
package dev.laszlo;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DatabaseService {

    private static final Logger logger = LoggerFactory.getLogger(DatabaseService.class);
    private static final String DB_URL = "jdbc:sqlite:storyforge.db";

    // Constructor - creates table if not exists
    public DatabaseService() {
        String createTableSQL = """
            CREATE TABLE IF NOT EXISTS messages (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                role TEXT NOT NULL,
                content TEXT NOT NULL,
                timestamp TEXT NOT NULL
            )
            """;

        try (Connection conn = DriverManager.getConnection(DB_URL);
             Statement stmt = conn.createStatement()) {
            stmt.execute(createTableSQL);
            logger.info("✅ Database initialized successfully");
        } catch (SQLException e) {
            logger.error("❌ Database initialization failed: {}", e.getMessage());
        }
    }

    // Save a message
    public void saveMessage(String role, String content) {
        String insertSQL = "INSERT INTO messages (role, content, timestamp) VALUES (?, ?, ?)";
        
        try (Connection conn = DriverManager.getConnection(DB_URL);
             PreparedStatement pstmt = conn.prepareStatement(insertSQL)) {
            pstmt.setString(1, role);
            pstmt.setString(2, content);
            pstmt.setString(3, java.time.LocalDateTime.now().toString());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            logger.error("❌ Failed to save message: {}", e.getMessage());
        }
    }

    // Load all messages
    public List<String[]> loadAllMessages() {
        List<String[]> messages = new ArrayList<>();
        String selectSQL = "SELECT role, content FROM messages ORDER BY id ASC";

        try (Connection conn = DriverManager.getConnection(DB_URL);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(selectSQL)) {
            while (rs.next()) {
                String role = rs.getString("role");
                String content = rs.getString("content");
                messages.add(new String[]{role, content});
            }
            logger.info("📂 Loaded {} messages from database", messages.size());
        } catch (SQLException e) {
            logger.error("❌ Failed to load messages: {}", e.getMessage());
        }
        return messages;
    }

    // Clear all messages
    public void clearAllMessages() {
        String deleteSQL = "DELETE FROM messages";

        try (Connection conn = DriverManager.getConnection(DB_URL);
             Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(deleteSQL);
            logger.info("🗑️ All messages cleared from database");
        } catch (SQLException e) {
            logger.error("❌ Failed to clear messages: {}", e.getMessage());
        }
    }
}
```

---

## ChatController Changes

### 1. Added field

```java
private final DatabaseService databaseService;
```

### 2. Initialize in constructor

```java
this.databaseService = new DatabaseService();

// Load existing messages from database
for (String[] msg : databaseService.loadAllMessages()) {
    if (msg[0].equals("user")) {
        history.addUserMessage(msg[1]);
    } else {
        history.addAssistantMessage(msg[1]);
    }
}
logger.info("📂 Loaded {} messages from history", history.getMessageCount());
```

### 3. Save messages in sendMessage()

```java
history.addUserMessage(userMessage);
databaseService.saveMessage("user", userMessage);  // ← Added

// ... get response from Claude ...

history.addAssistantMessage(response);
databaseService.saveMessage("assistant", response);  // ← Added
```

### 4. Clear database in resetChat()

```java
history.clear();
databaseService.clearAllMessages();  // ← Added
```

---

## SQL Commands Reference

| Command | Purpose | Example |
|---------|---------|---------|
| `CREATE TABLE` | Create new table | `CREATE TABLE messages (...)` |
| `INSERT INTO` | Add new row | `INSERT INTO messages VALUES (...)` |
| `SELECT` | Read data | `SELECT * FROM messages` |
| `DELETE` | Remove rows | `DELETE FROM messages` |
| `DROP TABLE` | Delete entire table | `DROP TABLE messages` |

---

## Java Database Classes Reference

| Class | Purpose |
|-------|---------|
| `DriverManager` | Creates database connections |
| `Connection` | Represents connection to database |
| `Statement` | Executes simple SQL |
| `PreparedStatement` | Executes SQL with parameters (safe!) |
| `ResultSet` | Holds query results (rows) |

---

## Testing Results

**Test 1: Send message**
```
✅ Database initialized successfully
📂 Loaded 0 messages from database
💾 Message saved: user - A knight enters a haunted castle
💾 Message saved: assistant - The iron-bound doors groaned...
```

**Test 2: Restart server**
```
✅ Database initialized successfully
📂 Loaded 2 messages from database
📂 Loaded 2 messages from history
```

**Test 3: Continue conversation**
- Claude remembered Sir Aldric and the haunted castle! ✅

---

## Common Errors & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `No suitable driver` | Missing dependency | Add sqlite-jdbc to pom.xml |
| `Table not found` | Database not initialized | Check constructor runs first |
| `Database is locked` | Multiple connections | Use try-with-resources |

---

## Project Progress

| Session | Achievement |
|---------|-------------|
| 1 | First API call to Claude |
| 2 | Interactive chat with memory |
| 3 | REST API with Spring Boot |
| 4 | Flutter frontend + monorepo |
| 5 | Database persistence ✅ |

---

## Next Steps

- Add user authentication (multiple users)
- Add conversation sessions (separate chats)
- Deploy backend to cloud
- Load prompt templates from /prompts folder

---

*Session 5 completed successfully! 🎉*

*Conversations now survive server restarts!*