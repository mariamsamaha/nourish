# Local Testing Guide

Before pushing code and creating a PR, run these checks locally to ensure CI will pass.

## Quick Pre-Push Checklist

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Format code (auto-fix)
dart format .

# 3. Run static analysis
flutter analyze

# 4. Run all tests
flutter test

# 5. Generate coverage (optional)
flutter test --coverage

# 6. Sanity build for Android
flutter build apk --debug

# 7. Sanity build for Web
flutter build web
```

## Detailed Commands

### 1. Install Dependencies
```bash
cd d:\Work\Learning\coourses\Y4S1\mobiledevcourse\mobildev proj\proj
flutter pub get
```

### 2. Format Check
```bash
# Check formatting (will show what would change)
dart format --output=none --set-exit-if-changed .

# Auto-format all files
dart format .
```

### 3. Static Analysis
```bash
flutter analyze --no-fatal-infos --fatal-warnings
```
Fix all warnings before proceeding.

### 4. Run Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/payment_link_handler_test.dart

# Run tests with verbose output
flutter test --reporter expanded
```

### 5. Generate Test Coverage
```bash
flutter test --coverage

# View coverage file
cat coverage/lcov.info
```

To view coverage in a more readable format, install `lcov` tools:
```bash
# On Windows (with Chocolatey)
choco install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
start coverage/html/index.html
```

### 6. Build Sanity Checks
```bash
# Android debug build
flutter build apk --debug --no-shrink

# Web build
flutter build web

# Check for build errors
```

## Common Issues and Solutions

### Issue: `flutter analyze` shows warnings
**Solution:** Fix warnings in the code. Common fixes:
- Add missing `const` keywords
- Remove unused imports
- Fix type mismatches

### Issue: Tests fail locally
**Solution:**
1. Check test output for specific failure
2. Verify mock data matches expected format
3. Update tests if implementation changed
4. Run `flutter clean` then `flutter pub get`

### Issue: Format check fails
**Solution:** Simply run `dart format .` to auto-fix

### Issue: Build fails
**Solution:**
1. Run `flutter clean`
2. Run `flutter pub get`
3. Check for platform-specific issues
4. Verify all dependencies are compatible

## Integration with IDE

### VS Code
Install extensions:
- Dart
- Flutter
- Flutter Test Runner (optional)

Use built-in tasks or create `.vscode/tasks.json`:
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Format",
      "type": "shell",
      "command": "dart format ."
    },
    {
      "label": "Analyze",
      "type": "shell",
      "command": "flutter analyze"
    },
    {
      "label": "Test",
      "type": "shell",
      "command": "flutter test"
    }
  ]
}
```

### Android Studio / IntelliJ
Use the built-in Flutter tools:
- **Dart Analysis** tab shows warnings
- **Run → Run Tests** to execute tests
- **Code → Reformat Code** for formatting

## CI Pipeline Locally (Docker - Optional)

To exactly replicate CI environment:
```bash
# Pull official Flutter Docker image
docker pull cirrusci/flutter:stable

# Run CI commands in container
docker run --rm -v ${PWD}:/app -w /app cirrusci/flutter:stable sh -c "
  flutter pub get &&
  dart format --output=none --set-exit-if-changed . &&
  flutter analyze --no-fatal-infos --fatal-warnings &&
  flutter test --coverage
"
```

## Recommended Workflow

1. **Before coding:** Create feature branch from `main`
   ```bash
   git checkout -b feature/my-feature
   ```

2. **During coding:** Run analyzer frequently
   ```bash
   flutter analyze
   ```

3. **Before commit:** Format and test
   ```bash
   dart format .
   flutter test
   ```

4. **Before push:** Full check
   ```bash
   dart format .
   flutter analyze
   flutter test --coverage
   flutter build apk --debug
   ```

5. **After push:** Create PR and wait for CI

## Time Estimates
- Format check: ~5 seconds
- Analyze: ~10-30 seconds
- Tests: ~30-60 seconds
- Coverage: ~40-70 seconds
- Android debug build: ~2-5 minutes
- Web build: ~1-3 minutes

**Total pre-push time:** ~5-10 minutes
