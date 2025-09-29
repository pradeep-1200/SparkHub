# SparkHub Testing & Build Commands

This document provides common commands for testing, analyzing, and building the SparkHub Flutter project.

---

## 🧪 Unit Tests
Run all unit tests:
```bash
flutter test test/unit/
```

Run a specific test file:
```bash
flutter test test/unit/models/user_model_test.dart
```

Run tests with coverage:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 🎨 Widget Tests
Run all widget tests:
```bash
flutter test test/widget/
```

Run a specific widget test:
```bash
flutter test test/widget/widgets/custom_button_test.dart
```

---

## 🔗 Integration Tests
Run all integration tests:
```bash
flutter drive --target=test_driver/app.dart
```

Run integration tests on a specific platform:
```bash
flutter drive --target=test_driver/app.dart -d android
flutter drive --target=test_driver/app.dart -d ios
```

---

## ⚡ Performance Testing
Profile app performance:
```bash
flutter run --profile
```

Analyze app build size:
```bash
flutter build apk --analyze-size
flutter build ios --analyze-size
```

---

## 🔍 Static Analysis & Security
Run static analysis:
```bash
flutter analyze
```

Check for outdated dependencies:
```bash
flutter pub outdated
```

View dependency tree (audit):
```bash
flutter pub deps
```

---

## 📦 Build Commands
Debug build:
```bash
flutter build apk --debug
flutter build ios --debug
```

Release build:
```bash
flutter build apk --release
flutter build ios --release
```

Build for a specific flavor (example: production):
```bash
flutter build apk --flavor production
```

---
