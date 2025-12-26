# Session 10 Plan: Automated Testing 🧪

**Date:** December 26, 2025 (Afternoon)  
**Branch:** TBD (likely `feature/automated-tests` or similar)  
**Goal:** Build automated test suite to prevent regressions

---

## Session 10 Objectives

### Primary Goal
Build a comprehensive automated test suite that catches bugs like the `created_at` SELECT query issue automatically, preventing future regressions.

### Success Criteria
- ✅ Backend unit tests for DatabaseService
- ✅ API integration tests for ChatController endpoints
- ✅ At least one regression test for the bug we just fixed
- ✅ Tests run successfully in local development
- ✅ Documentation for running and adding tests

---

## Your Background

**Relevant Experience:**
- ✅ Java development
- ✅ Selenium automation testing
- ✅ Understanding of test workflows and best practices

**Project Knowledge:**
- ✅ Spring Boot 3.2.1 backend
- ✅ SQLite database operations
- ✅ REST API endpoints under `/api/chat`
- ✅ Recent bug: SELECT query missing column that code tried to read

---

## Recommended Approach

### Phase 1: Backend Unit Tests (Start Here) ⭐
**Why:** You know Java, these are fastest to write, catch most bugs

**What to Test:**
1. **DatabaseService Tests**
    - `createSession()` - Verify session creation returns valid ID
    - `getAllSessions()` - **Regression test:** Verify returned data includes `created_at`
    - `loadMessages()` - Verify message retrieval for session
    - `saveMessage()` - Verify message persistence
    - Edge cases: Empty database, invalid session IDs, null values

2. **Session Model Tests**
    - Constructor validation
    - JSON serialization/deserialization
    - Null safety checks

**Technology Stack:**
- JUnit 5 (already in Spring Boot)
- H2 in-memory database (for test isolation)
- Spring Boot Test (@SpringBootTest)
- MockMvc (for API testing)

**Estimated Time:** 1-2 hours

---

### Phase 2: API Integration Tests
**Why:** Test actual endpoints that frontend calls

**What to Test:**
1. `GET /api/chat/sessions` - Returns session list with all fields
2. `POST /api/chat/sessions` - Creates new session
3. `PUT /api/chat/sessions/{id}/switch` - Switches session and loads messages
4. `POST /api/chat/send` - Sends message and gets response
5. `GET /api/chat/status` - Health check

**Key Scenarios:**
- Happy path (everything works)
- Empty database
- Invalid session IDs
- Missing request parameters

**Estimated Time:** 1-2 hours

---

### Phase 3: End-to-End Tests (Optional)
**Why:** Your Selenium expertise, tests real user flows

**What to Test:**
- Create session → Send message → Switch → Verify persistence
- Multi-session management
- Session switching doesn't lose data

**Technology:**
- Selenium WebDriver (your expertise!)
- Chrome/Firefox driver
- Test against `flutter run -d chrome`

**Estimated Time:** 2-3 hours (if time permits)

---

## Test Project Structure

```
backend/
├── src/
│   ├── main/java/dev/laszlo/
│   │   ├── DatabaseService.java
│   │   ├── ChatController.java
│   │   └── Session.java
│   └── test/java/dev/laszlo/          ← NEW
│       ├── DatabaseServiceTest.java    ← Phase 1
│       ├── SessionTest.java            ← Phase 1
│       ├── ChatControllerTest.java     ← Phase 2
│       └── integration/                ← Phase 2
│           └── ApiIntegrationTest.java
```

---

## Specific Regression Test for Today's Bug

**Critical Test Case:**

```java
@Test
void getAllSessions_shouldIncludeCreatedAtField() {
    // GIVEN: A session exists in database
    int sessionId = databaseService.createSession("Test Session");
    
    // WHEN: Retrieving all sessions
    List<Session> sessions = databaseService.getAllSessions();
    
    // THEN: Session should include createdAt field
    assertNotNull(sessions);
    assertFalse(sessions.isEmpty());
    Session session = sessions.get(0);
    assertNotNull(session.getCreatedAt(), 
        "Bug regression: created_at must be included in SELECT query");
}
```

**This test would have caught the bug immediately!**

---

## Commands Reference

### Run Tests
```bash
# Run all tests
cd backend
mvn test

# Run specific test class
mvn test -Dtest=DatabaseServiceTest

# Run with coverage report
mvn test jacoco:report
```

### Test Database Setup
```java
// Use H2 in-memory database for tests
// Add to application-test.properties:
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driver-class-name=org.h2.Driver
```

---

## Dependencies to Add (if missing)

Add to `pom.xml` if not already present:

```xml
<dependencies>
    <!-- Spring Boot Test Starter (includes JUnit 5, Mockito) -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
    
    <!-- H2 Database for testing -->
    <dependency>
        <groupId>com.h2database</groupId>
        <artifactId>h2</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

---

## Success Metrics for Session 10

**Minimum Viable Tests (MVP):**
- ✅ 5-10 unit tests for DatabaseService
- ✅ 3-5 integration tests for API endpoints
- ✅ 1 regression test for today's bug
- ✅ All tests passing
- ✅ Documentation on running tests

**Stretch Goals:**
- 🎯 Test coverage > 70% for critical classes
- 🎯 Selenium E2E test for session persistence
- 🎯 CI/CD integration (GitHub Actions)

---

## Session Flow

### Step 1: Setup (15 min)
- Create feature branch
- Verify test dependencies
- Create test directory structure
- Configure H2 test database

### Step 2: Unit Tests (45-60 min)
- Write DatabaseService tests
- Write Session model tests
- Focus on regression test for SELECT query bug

### Step 3: Integration Tests (45-60 min)
- Write API endpoint tests
- Test session creation, switching, message sending
- Verify JSON responses

### Step 4: Run & Verify (15 min)
- Execute full test suite
- Fix any failures
- Verify coverage

### Step 5: Document (15 min)
- Update README with test instructions
- Document test structure
- Commit and push

---

## Expected Challenges

1. **H2 vs SQLite differences**
    - Solution: Use H2 syntax compatible with SQLite, or use SQLite for tests too

2. **Test database isolation**
    - Solution: Use `@BeforeEach` to create fresh database, `@AfterEach` to clean up

3. **API key for ChatService**
    - Solution: Mock ChatService in tests, don't call real Claude API

4. **Time-based tests**
    - Solution: Don't test exact timestamps, just verify field exists and is valid

---

## Resources

**Spring Boot Testing:**
- https://spring.io/guides/gs/testing-web
- https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.testing

**JUnit 5:**
- https://junit.org/junit5/docs/current/user-guide/

**Selenium (if doing E2E):**
- https://www.selenium.dev/documentation/

---

## Post-Session 10

**What's Next:**
- Session 11: CI/CD pipeline (GitHub Actions)
- Session 12: Flutter widget tests
- Session 13: Mobile persistence fix
- Session 14: Deployment automation

---

## Quick Start Commands for Next Session

```bash
# Navigate to project
cd D:\java-projects\StoryForge\backend

# Create feature branch
git checkout -b feature/automated-tests

# Verify Maven setup
mvn clean test

# Create test directory structure
mkdir -p src/test/java/dev/laszlo

# Ready to write tests!
```

---

**Session 10 is focused, achievable, and valuable!** We'll build the foundation that prevents bugs like today's from ever happening again. 🛡️

See you in the next session, Laszlo! 🚀