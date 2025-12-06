# Nourish - Sustainable Food & Charity Mobile App

A Flutter-based mobile application that helps users discover sustainable restaurants, support local charities, and make conscious food choices. Built for cross-platform deployment (iOS, Android, Web).

---

## 🚀 Features

- **Restaurant Discovery** - Browse and filter sustainable restaurants with location-based services
- **Smart Food Scanning** - AI-powered food analysis using camera or gallery images
- **Charity Integration** - Support local charities with donation tracking and impact visualization
- **User Profiles** - Personalized favorites, preferences, and account management
- **Payment Integration** - Secure payments via Paymob gateway with WebView bridge
- **AI Chat Support** - Intelligent chatbot for user assistance
- **Multi-platform** - Runs on iOS, Android, and Web (Chrome)

---

## 📋 Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- [Firebase Account](https://firebase.google.com/) for backend services
- [Android Studio](https://developer.android.com/studio) or [Xcode](https://developer.apple.com/xcode/) for mobile development
- [Chrome Browser](https://www.google.com/chrome/) for web development

---

## 🛠️ Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd proj
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add your `google-services.json` (Android) to `android/app/`
3. Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`
4. Configure Firestore database and Authentication

### 4. Run the App

```bash
# Run on Chrome (Web)
flutter run -d chrome

# Run on connected device
flutter run

# Run on specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

---

## 🧪 Testing

We maintain a comprehensive test suite to ensure code quality and prevent regressions.

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage report
flutter test --coverage

# Run specific test file
flutter test test/payment_link_handler_test.dart

# Run with verbose output
flutter test --reporter=expanded
```

### Test Coverage

- **Unit Tests** - Payment handlers, utilities, business logic
- **Widget Tests** - UI components, screens, form validation
- **Integration Tests** - End-to-end user flows *(planned)*

See [`testing_status.md`](../testing_status.md) for detailed test documentation.

> [!IMPORTANT]
> All tests **must pass** before submitting a pull request. CI/CD will automatically reject failing test suites.

---

## 👨‍💻 Contributing - Developer Workflow

We follow a **feature branch workflow** with mandatory CI/CD checks and senior approval before merging to production.

### Step-by-Step Contribution Process

#### 1️⃣ Create a Feature Branch

```bash
# Pull latest changes from main
git checkout main
git pull origin main

# Create a new feature branch
git checkout -b feature/<feature-name>
# Examples: feature/add-restaurant-filters, feature/improve-chat-ui
```

**Branch Naming Conventions:**
- `feature/<name>` - New features
- `fix/<name>` - Bug fixes
- `refactor/<name>` - Code refactoring
- `test/<name>` - Adding/updating tests
- `docs/<name>` - Documentation updates

---

#### 2️⃣ Implement Your Feature

1. **Write Code** - Implement your feature following the existing code structure
2. **Add Tests** - Write unit/widget tests for new functionality
3. **Update Documentation** - Update relevant docs if needed

**Code Quality Checklist:**
- [ ] Code follows Dart style guidelines (`flutter analyze`)
- [ ] No compiler warnings or errors
- [ ] New code includes appropriate comments
- [ ] Reusable components are properly modularized
- [ ] No hardcoded values (use constants/config)

---

#### 3️⃣ Write Tests for Your Changes

> [!CAUTION]
> **Never commit code without tests!** Untested code will be rejected in code review.

**Test Requirements:**
- Add unit tests for business logic in `test/`
- Add widget tests for UI components in `test/widget/`
- Ensure all new tests **pass locally** before committing

```bash
# Verify tests pass before committing
flutter test
```

---

#### 4️⃣ Commit Your Changes

```bash
# Stage your changes
git add .

# Commit with descriptive message
git commit -m "feat: add restaurant filter by cuisine type

- Added dropdown filter for cuisine selection
- Implemented filter state management
- Added unit tests for filter logic"
```

**Commit Message Format:**
```
<type>: <short summary>

<optional detailed description>
<list of changes>
```

**Types:** `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `style`

---

#### 5️⃣ Push to Remote and Create Pull Request

```bash
# Push your feature branch
git push origin feature/<feature-name>
```

**On GitHub/GitLab:**
1. Navigate to the repository
2. Click "New Pull Request"
3. Select `feature/<feature-name>` → `main`
4. Fill out PR template:
   - **Title**: Clear, concise description
   - **Description**: What does this PR do?
   - **Testing**: How was this tested?
   - **Screenshots**: If UI changes, include before/after images

**PR Title Examples:**
- ✅ `feat: Add restaurant filtering by price range`
- ✅ `fix: Resolve payment redirect on web platform`
- ✅ `test: Add widget tests for profile screen`

---

#### 6️⃣ CI/CD Pipeline Runs Automatically

Once you create the PR, our **Continuous Integration (CI)** pipeline will automatically:

1. ✅ **Lint Check** - Runs `flutter analyze` to check code quality
2. ✅ **Build Check** - Compiles the app for all platforms
3. ✅ **Test Suite** - Runs all unit and widget tests
4. ✅ **Coverage Report** - Generates test coverage metrics

**Pipeline Status:**
- 🟢 **All checks passed** - PR is ready for review
- 🔴 **Checks failed** - Fix issues and push again

> [!WARNING]
> **Pull requests with failing CI checks will NOT be reviewed.** Fix all issues before requesting review.

---

#### 7️⃣ Code Review by Senior Developer

After CI passes, a **senior developer** will review your PR:

**Review Criteria:**
- Code quality and readability
- Adherence to project architecture
- Test coverage sufficiency
- Performance considerations
- Security best practices

**Possible Outcomes:**
- ✅ **Approved** - PR is ready to merge
- 🔄 **Changes Requested** - Address feedback and push updates
- ❌ **Rejected** - Major issues; may need redesign

**Addressing Review Comments:**
```bash
# Make requested changes
git add .
git commit -m "refactor: address PR feedback - improve error handling"
git push origin feature/<feature-name>
```

The CI pipeline will run again automatically.

---

#### 8️⃣ Merge to Main

Once approved by senior developer and CI is green:

1. **Squash and Merge** (recommended) - Combines all commits into one
2. **Senior/Maintainer** performs the merge
3. Your feature is now in production! 🎉

**Post-Merge:**
```bash
# Delete local feature branch
git checkout main
git pull origin main
git branch -d feature/<feature-name>

# Delete remote branch (if not auto-deleted)
git push origin --delete feature/<feature-name>
```

---

## 📊 CI/CD Pipeline Details

### Automated Checks

| Check | Tool | Passing Criteria |
|-------|------|------------------|
| Code Analysis | `flutter analyze` | Zero errors/warnings |
| Unit Tests | `flutter test` | 100% pass rate |
| Build Verification | `flutter build` | Successful compilation |
| Code Coverage | `--coverage` | Meets minimum threshold |

### Manual Checks

- **Code Review** - Senior developer approval
- **UI/UX Review** - Design consistency (for UI changes)
- **Security Review** - No vulnerabilities introduced

---

## 🏗️ Project Structure

```
proj/
├── lib/
│   ├── main.dart              # App entry point
│   ├── routes/                # Navigation routes
│   ├── screens/               # UI screens
│   ├── widgets/               # Reusable widgets
│   ├── services/              # Business logic, APIs
│   ├── utils/                 # Helper functions
│   └── models/                # Data models
├── test/
│   ├── widget/                # Widget tests
│   └── *.dart                 # Unit tests
├── integration_test/          # E2E tests (future)
├── android/                   # Android-specific code
├── ios/                       # iOS-specific code
├── web/                       # Web-specific code
└── pubspec.yaml               # Dependencies

```

---

## 🐛 Troubleshooting

### Common Issues

**Issue: Tests failing locally**
```bash
# Clear cache and reinstall dependencies
flutter clean
flutter pub get
flutter test
```

**Issue: Firebase not configured**
- Ensure `google-services.json` / `GoogleService-Info.plist` are in correct locations
- Verify Firebase project settings match app bundle IDs

**Issue: Hot reload not working**
```bash
# Restart the app
r  # Hot reload
R  # Hot restart
```

---

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Guide](https://dart.dev/guides)
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)
- [Testing Flutter Apps](https://docs.flutter.dev/testing)

---

## 📞 Support

For questions or issues:
- Check existing [GitHub Issues](./issues)
- Contact the development team lead
- Refer to [testing_status.md](../testing_status.md) for test-related queries

---

## 📄 License

This project is part of a mobile development course at [University Name].

**Version:** 1.0.0  
**Last Updated:** 2025-12-06
