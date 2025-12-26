# Session 11 Plan: CI/CD Pipeline with GitHub Actions 🔄

**Date:** December 26, 2025 (Evening)  
**Branch:** `feature/ci-cd-pipeline`  
**Goal:** Automate test execution on every push/PR using GitHub Actions

---

## Session 11 Objectives

### Primary Goal
Set up GitHub Actions to automatically run our 21 tests on every push and pull request, catching bugs before they reach main branch.

### Success Criteria
- ✅ GitHub Actions workflow configured
- ✅ Tests run automatically on push to any branch
- ✅ Tests run on pull requests
- ✅ Build status visible in GitHub
- ✅ (Optional) Status badge in README

---

## What We'll Build

### GitHub Actions Workflow

**Triggers:**
- Push to any branch
- Pull requests to main branch
- Manual workflow dispatch (for testing)

**Jobs:**
1. **Backend Tests** - Run Maven tests
2. **Build Verification** - Ensure project builds
3. **Test Report** - Generate test results

**Environment:**
- Java 21 (matches your local setup)
- Ubuntu latest
- Maven 3.x

---

## Implementation Plan

### Step 1: Create Workflow File (15 min)

Create `.github/workflows/backend-ci.yml`

**What it does:**
- Checks out code
- Sets up Java 21
- Runs `mvn test`
- Uploads test results

### Step 2: Configure Maven for CI (5 min)

Ensure `pom.xml` works in CI environment:
- H2 database (already configured)
- No environment variables needed for tests (already done)
- Clean build process

### Step 3: Test the Workflow (10 min)

- Push to feature branch
- Watch GitHub Actions run
- Verify tests pass
- Check output logs

### Step 4: Add Status Badge (5 min)

Add badge to README showing build status:
`![CI Status](https://github.com/username/repo/workflows/Backend%20CI/badge.svg)`

### Step 5: Document (5 min)

Update README with CI/CD information

---

## GitHub Actions Workflow Structure
```yaml
name: Backend CI

on:
  push:
    branches: [ "**" ]  # All branches
  pull_request:
    branches: [ "main" ]
  workflow_dispatch:  # Manual trigger

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
    - name: Set up Java 21
    - name: Cache Maven dependencies
    - name: Run tests
    - name: Upload test results
```

---

## Expected Timeline

**Total Time:** ~40 minutes

1. Create workflow file: 15 min
2. Push and test: 10 min
3. Add badge: 5 min
4. Documentation: 10 min

---

## Benefits

### Immediate
- ✅ Automated test execution
- ✅ Catch bugs before merge
- ✅ Build verification on every push
- ✅ PR quality gates

### Long-term
- ✅ Confidence in deployments
- ✅ No manual test running
- ✅ Team collaboration ready
- ✅ Professional workflow

---

## Future Enhancements (Post-Session 11)

### Optional Additions
- 🎯 Deployment to Railway on main branch
- 🎯 Test coverage reporting
- 🎯 Slack/Discord notifications
- 🎯 Flutter web build
- 🎯 Docker image building

**Note:** We'll keep Session 11 focused on the basics - just get tests running automatically!

---

## Prerequisites

- ✅ GitHub repository exists
- ✅ Tests pass locally (21 tests)
- ✅ Maven project configured
- ✅ Java 21 setup

---

## Commands Reference

### Create Feature Branch
```bash
git checkout -b feature/ci-cd-pipeline
```

### Test Locally First
```bash
cd backend
mvn clean test
```

### Push and Watch
```bash
git add .
git commit -m "feat: Add GitHub Actions CI/CD pipeline"
git push origin feature/ci-cd-pipeline
```

**Then:** Go to GitHub → Actions tab → Watch workflow run

---

## Success Indicators

**You'll know it's working when:**
1. ✅ Green checkmark appears on commit in GitHub
2. ✅ Actions tab shows successful workflow run
3. ✅ Test results visible in workflow logs
4. ✅ All 21 tests passing in CI

---

## Quick Start

Ready to begin? Let's:
1. Create feature branch
2. Create workflow file
3. Push and test
4. Add badge
5. Merge to main

**Estimated time to completion:** 40 minutes

Let's automate those tests! 🚀