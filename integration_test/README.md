# 🧪 Integration Tests

This directory contains integration tests for the MyNotes Flutter app using Flutter's integration test package and BrowserStack App Automate.

## 📁 Directory Structure

```
integration_test/
├── app_test.dart                   # Basic integration tests
├── app_integration_test.dart       # Comprehensive test suite
├── test_utils.dart                 # Test utility functions
├── integration_test_config.md      # Configuration guide
└── README.md                       # This file
```

## 🚀 Quick Start

### Local Testing

Run all integration tests on a connected device:

```bash
# Run with flutter test
flutter test integration_test/app_test.dart

# Run with flutter drive
flutter drive --target=integration_test/app_test.dart
```

Run on specific device:

```bash
flutter test integration_test/app_test.dart -d <device-id>
```

### BrowserStack Testing

See [BROWSERSTACK_SETUP_GUIDE.md](../BROWSERSTACK_SETUP_GUIDE.md) for detailed setup instructions.

Quick upload and run:

```bash
# PowerShell (Windows)
./scripts/browserstack_upload.ps1

# Bash (Linux/Mac)
chmod +x scripts/browserstack_upload.sh
./scripts/browserstack_upload.sh
```

## 📋 Test Files

### `app_test.dart`
Basic integration tests that verify:
- App launches successfully
- App responds to user interactions
- Accessibility features work correctly

**Good for**: Initial validation and quick smoke tests

### `app_integration_test.dart`
Comprehensive test suite covering:
- **Core Features**: App launch, UI initialization, interactions
- **Navigation**: Back navigation, state preservation
- **Performance**: Load time thresholds, rapid interactions
- **Accessibility**: Text scaling, semantic labels, haptic feedback

**Good for**: Full regression testing and quality assurance

### `test_utils.dart`
Helper utilities for common testing tasks:
- Wait for app to settle
- Verify widgets exist/absent
- Tap and wait pattern
- Enter text with settlement
- Screenshot capture

**Good for**: Reducing boilerplate in test files

## 🔧 Configuration

See [integration_test_config.md](./integration_test_config.md) for:
- Test settings and parameters
- Device configuration for BrowserStack
- Performance thresholds
- Environment variables
- Debugging tips

## 🛠️ Writing Integration Tests

### Basic Test Structure

```dart
testWidgets('Test description', (WidgetTester tester) async {
  app.main();
  await IntegrationTestUtils.waitForAppToSettle(tester);
  
  // Test actions
  await IntegrationTestUtils.tapAndSettle(tester, find.byIcon(Icons.add));
  
  // Verify results
  IntegrationTestUtils.verifyWidgetExists(find.byType(TextField));
});
```

### Common Patterns

**Tap and verify:**
```dart
await IntegrationTestUtils.tapAndSettle(tester, find.byText('Save'));
expect(find.byText('Saved!'), findsWidgets);
```

**Enter text:**
```dart
await IntegrationTestUtils.enterText(
  tester,
  find.byType(TextField),
  'My test note'
);
```

**Wait for specific widget:**
```dart
await tester.pumpWidget(MyApp());
expect(find.byType(HomePage), findsWidgets);
```

## 🌍 BrowserStack Integration

### Prerequisites

1. BrowserStack Account
2. BrowserStack Username and API Key
3. APKs built for Android testing

### Steps

1. **Set up credentials:**
   ```bash
   export BS_USERNAME=your_username
   export BS_API_KEY=your_api_key
   ```

2. **Build APKs:**
   ```bash
   cd android
   ./gradlew app:assembleDebug -Ptarget="../integration_test/app_test.dart"
   ./gradlew app:assembleAndroidTest
   cd ..
   ```

3. **Upload and run:**
   ```bash
   ./scripts/browserstack_upload.ps1  # Windows
   ./scripts/browserstack_upload.sh   # Linux/Mac
   ```

4. **View results:**
   Visit [BrowserStack Dashboard](https://app-automate.browserstack.com)

## 🔄 CI/CD Integration

GitHub Actions workflow is configured at `.github/workflows/integration-tests-browserstack.yml`

Triggers:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Manual workflow dispatch

### Secrets to Configure

In GitHub Settings > Secrets and variables > Actions:
- `BROWSERSTACK_USERNAME`
- `BROWSERSTACK_API_KEY`

### Run on Push

Tests run automatically on push to main/develop. View results in:
- GitHub Actions tab
- BrowserStack Dashboard

## 📊 Test Reports

### Local Reports

After running tests, check:
- Console output for pass/fail status
- Test timing information

### BrowserStack Reports

Access from:
1. BrowserStack Dashboard
2. GitHub Actions job summary
3. Build ID for direct access

## 🐛 Debugging Failed Tests

### Common Issues

**Test times out:**
- Increase timeout in widget tester
- Check for missing `pumpAndSettle()` calls
- Verify app state doesn't block waiting

**Widget not found:**
- Check widget hierarchy
- Use `find.byType()` for better debugging
- Capture screenshot on failure

**Flaky tests:**
- Increase settlement duration
- Add explicit waits for animations
- Mock external dependencies

### Debug Commands

```bash
# Verbose output
flutter test --verbose integration_test/app_test.dart

# Run specific test
flutter test integration_test/app_test.dart -p "Test name"

# Enable device logging
flutter drive --target=integration_test/app_test.dart -v
```

## 📚 Resources

- [Flutter Integration Testing Docs](https://flutter.dev/docs/testing/integration-tests)
- [BrowserStack App Automate](https://www.browserstack.com/app-automate)
- [Flutter Testing Best Practices](https://flutter.dev/docs/testing)
- [Integration Test Package](https://pub.dev/packages/integration_test)

## 🎯 Test Coverage Goals

- **Core Features**: >80% coverage
- **Accessibility**: >90% coverage
- **Navigation**: >85% coverage
- **Error Handling**: >75% coverage

## 💡 Tips

1. **Test user workflows** - Don't just test individual widgets
2. **Keep tests independent** - No test should depend on another
3. **Use descriptive names** - Make it clear what's being tested
4. **Mock when possible** - Reduce dependency on external resources
5. **Parallel execution** - Run tests on multiple devices simultaneously

## 🤝 Contributing

When adding new tests:

1. Follow naming convention: `test_<feature>_<scenario>.dart`
2. Use `IntegrationTestUtils` helper functions
3. Add comments explaining test intent
4. Ensure tests pass locally before pushing
5. Update this README if adding new test categories

## 📝 Checklist

- [ ] Tests pass locally on Android device
- [ ] Tests pass locally on iOS device (if applicable)
- [ ] BrowserStack credentials configured
- [ ] APKs build without errors
- [ ] Tests run successfully on BrowserStack
- [ ] CI/CD workflow triggers correctly
- [ ] GitHub Actions secrets configured

## ❓ FAQ

**Q: Why do tests fail on BrowserStack but pass locally?**
A: Different device configurations, timing issues, or missing resources. Use screenshots/videos from BrowserStack to debug.

**Q: How do I add custom assertions?**
A: Create utility functions in `test_utils.dart` to reuse across tests.

**Q: Can I run tests on iOS?**
A: Yes, but you'll need to upload `.app` files instead of APKs to BrowserStack.

**Q: What's the maximum test duration?**
A: BrowserStack has a 10-minute timeout per test suite by default.

---

**Last Updated**: February 2026  
**Status**: ✅ Production Ready
