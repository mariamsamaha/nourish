# How to Get CI/CD Working - Step by Step Guide

Follow these steps **exactly** in order. Don't skip any step!

---

## PART 1: Test Locally First (15-20 minutes)

### Step 1: Open Terminal/Command Prompt
1. Press `Windows + R`
2. Type `cmd` and press Enter
3. Navigate to your project:
   ```
   cd "d:\Work\Learning\coourses\Y4S1\mobiledevcourse\mobildev proj\proj"
   ```

### Step 2: Install Dependencies
Run this command:
```bash
flutter pub get
```
Wait for it to complete (should say "Got dependencies!").

### Step 3: Run the Tests
Run this command:
```bash
flutter test test/payment_link_handler_test.dart
```

**Expected result:** Should say "All tests passed!" with `+6` (6 tests passed).

If it fails, **STOP** and tell me the error message.

### Step 4: Format Your Code
Run this command:
```bash
dart format .
```

**Expected result:** Should format all files and show which ones were changed.

### Step 5: Run Static Analysis
Run this command:
```bash
flutter analyze
```

**Expected result:** Should say "No issues found!" or show warnings to fix.

✅ **If all 5 steps above work, continue to Part 2.**

---

## PART 2: Set Up GitHub Repository (10-15 minutes)

### Step 6: Check if You Have a GitHub Account
1. Go to https://github.com
2. If you don't have an account, click "Sign up" and create one
3. If you have an account, log in

### Step 7: Create a New Repository (if you don't have one)

**Option A: If you already have a repository for this project**
- Skip to Step 8

**Option B: If you need to create a new repository**
1. Click the **+** icon in top right → "New repository"
2. Repository name: `nourish-app` (or whatever you want)
3. Set to **Private** (recommended for school projects)
4. **DO NOT** check "Initialize with README"
5. Click "Create repository"

### Step 8: Connect Your Local Project to GitHub

**First, check if you already have git initialized:**
```bash
git status
```

**If it says "not a git repository":**
```bash
git init
git branch -M main
```

**If it shows files, you're good. Continue:**

### Step 9: Add Your Files to Git
```bash
git add .
git commit -m "Add CI/CD pipeline with automated tests"
```

### Step 10: Link to Your GitHub Repository

**Replace `YOUR_USERNAME` and `YOUR_REPO_NAME` with your actual GitHub username and repository name:**

```bash
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
```

**Example:**
```bash
git remote add origin https://github.com/mariam123/nourish-app.git
```

### Step 11: Push to GitHub
```bash
git push -u origin main
```

**If it asks for credentials:**
- Username: Your GitHub username
- Password: Use a Personal Access Token (see Step 11a below)

#### Step 11a: Create Personal Access Token (if needed)
1. Go to https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Give it a name: "Nourish App"
4. Check the box: `repo` (full control of private repositories)
5. Click "Generate token" at the bottom
6. **COPY THE TOKEN** (you won't see it again!)
7. Use this token as your password when pushing

✅ **Your code is now on GitHub!**

---

## PART 3: Verify CI Works (5-10 minutes)

### Step 12: Check if Workflow File Exists on GitHub
1. Go to your repository on GitHub
2. Look for `.github/workflows/ci.yml` in the file list
3. If you see it, ✅ good!
4. If not, double-check that you pushed everything

### Step 13: Go to Actions Tab
1. In your GitHub repository, click the **"Actions"** tab
2. You should see a workflow run (might be in progress or completed)
3. Click on the workflow run to see details

**Expected result:**
- All green checkmarks ✅
- If you see red X's ❌, click on them to see what failed

### Step 14: Create a Test PR to Verify CI

**Create a new branch:**
```bash
git checkout -b test/verify-ci
```

**Make a small change (add a comment anywhere):**
Open `lib\main.dart` and add a comment at the top:
```dart
// CI/CD test - this is a test PR
import 'package:flutter/material.dart';
```

**Commit and push:**
```bash
git add .
git commit -m "test: Verify CI pipeline"
git push origin test/verify-ci
```

### Step 15: Create Pull Request on GitHub
1. Go to your repository on GitHub
2. You'll see a yellow banner saying "test/verify-ci had recent pushes"
3. Click **"Compare & pull request"**
4. Review the PR template (you should see our checklist!)
5. Click **"Create pull request"**

### Step 16: Watch CI Run
1. In your PR, you'll see a **"Checks"** section
2. Wait for the `build-and-test` check to run (might take 3-5 minutes)
3. It should turn **green** ✅

**If it fails:**
- Click "Details" to see the logs
- Find which step failed
- Tell me the error and I'll help you fix it

✅ **If CI passes, your pipeline is working!**

---

## PART 4: Set Up Branch Protection (Optional but Recommended)

### Step 17: Enable Branch Protection
1. In your GitHub repository, click **Settings** (top right)
2. Click **Branches** in the left sidebar
3. Under "Branch protection rules", click **Add rule**
4. Branch name pattern: `main`
5. Check these boxes:
   - ✅ **Require a pull request before merging**
   - ✅ **Require status checks to pass before merging**
     - In the search box, type `build-and-test` and select it
6. Scroll down and click **Create**

**Now you cannot merge PRs unless CI passes!**

---

## PART 5: Daily Workflow (What to Do From Now On)

### When you want to make changes:

**1. Create a new branch:**
```bash
git checkout main
git pull
git checkout -b feature/my-feature-name
```

**2. Make your changes** (code, add files, etc.)

**3. Before committing, run locally:**
```bash
dart format .
flutter analyze
flutter test
```

**4. Commit and push:**
```bash
git add .
git commit -m "feat: description of what you did"
git push origin feature/my-feature-name
```

**5. Create a PR on GitHub**
- Go to your repo
- Click "Compare & pull request"
- Wait for CI to pass ✅
- Review and merge

---

## Troubleshooting

### "flutter test" fails
**Solution:**
```bash
flutter clean
flutter pub get
flutter test
```

### Git push asks for password but won't accept it
**Solution:** Use a Personal Access Token (see Step 11a)

### CI fails with "coverage/lcov.info not found"
**Solution:** This is okay! The warning won't fail the build.

### CI fails on "flutter analyze"
**Solution:**
```bash
flutter analyze
```
Fix the warnings shown, then push again.

### Can't find `build-and-test` in branch protection
**Solution:** 
- Make sure the workflow has run at least once
- Check the Actions tab to confirm
- Wait a few minutes and try again

---

## Quick Reference Commands

```bash
# Run tests
flutter test

# Format code
dart format .

# Analyze code
flutter analyze

# Create new branch
git checkout -b feature/my-feature

# See current branch
git branch

# Switch to main
git checkout main

# Update from remote
git pull

# Push changes
git push origin YOUR_BRANCH_NAME
```

---

## What Each File Does

📁 `.github/workflows/ci.yml` - Tells GitHub Actions what to run  
📁 `.github/PULL_REQUEST_TEMPLATE.md` - Template for PRs  
📁 `lib/utils/payment_link_handler.dart` - Parses payment links  
📁 `test/payment_link_handler_test.dart` - Tests for payment handler  
📁 `test/widget/login_test.dart` - Tests for login screen  
📁 `test/widget/navigation_test.dart` - Tests for navigation  
📁 `test/widget/webview_bridge_test.dart` - Tests for WebView  

---

## Need Help?

If you get stuck at any step:
1. **Copy the exact error message**
2. **Tell me which step number you're on**
3. **Show me the command you ran**

I'll help you fix it!
