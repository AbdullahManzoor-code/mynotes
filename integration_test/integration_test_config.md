# Integration Test Configuration

This file contains configuration settings for the integration tests in your MyNotes app.

## Test Settings

### Local Testing
```dart
// Enable debug logging
bool enableLogging = true;

// Timeout for each test (in seconds)
int testTimeout = 30;

// Wait for app settlement after each action
Duration settleDuration = Duration(seconds: 2);
```

### BrowserStack Testing

#### Devices Configuration
```yaml
devices:
  - name: "Google Pixel 7-13.0"
    priority: 1  # Primary testing device
  - name: "Google Pixel 6-12.0"
    priority: 2
  - name: "Samsung Galaxy S23-13.0"
    priority: 3
```

#### Test Execution Parameters
```yaml
testExecution:
  timeoutMinutes: 10
  retryOnFailure: true
  maxRetries: 1
  captureScreenshots: true
  recordVideo: true
```

## Test Suites

### Core Features Tests
- App initialization and launch
- Home page rendering
- Navigation between screens
- State persistence

### Accessibility Tests
- Text scaling support
- Semantic labels
- Touch target sizes
- Color contrast

### Performance Tests
- App launch time (< 5 seconds)
- Navigation latency (< 2 seconds)
- Memory usage monitoring

### Integration Tests
- Feature interaction
- Data persistence
- Network requests
- Error handling

## Custom Test Properties

### Environment Variables

```bash
# BrowserStack Credentials
export BS_USERNAME=your_username
export BS_API_KEY=your_api_key

# Test Configuration
export TEST_DEVICE="Google Pixel 7-13.0"
export TEST_TIMEOUT=30
export ENABLE_VIDEO_RECORDING=true
```

### Gradle Properties

Add to `android/gradle.properties`:
```properties
# Integration Test Settings
inttest.device=Google Pixel 7-13.0
inttest.timeout=10m
inttest.skipScreenshots=false
```

## Performance Thresholds

```dart
// App launch time threshold
const Duration appLaunchThreshold = Duration(seconds: 5);

// Navigation time threshold
const Duration navigationThreshold = Duration(seconds: 2);

// Test action timeout
const Duration actionTimeout = Duration(seconds: 30);

// Screenshot capture delay
const Duration screenshotDelay = Duration(milliseconds: 500);
```

## Custom Test Finders

```dart
// Navigate to Note Creation Screen
Finder noteCreateButton = find.byIcon(Icons.add);

// Find note list items
Finder noteListItems = find.byType(ListTile);

// Find save button
Finder saveButton = find.byType(ElevatedButton);
```

## Debugging

### Enable Verbose Logging
```bash
flutter test --verbose integration_test/app_test.dart
```

### Run Specific Test
```bash
flutter test integration_test/app_test.dart -p app_integration_test
```

### Debug in Isolate
```bash
flutter drive \
  --target=integration_test/app_test.dart \
  --driver=integration_test/test_driver/driver.dart \
  -v
```

## Continuous Integration

### GitHub Actions Secrets

Configure these secrets in GitHub Actions:
- `BROWSERSTACK_USERNAME`: Your BrowserStack username
- `BROWSERSTACK_API_KEY`: Your BrowserStack API key

### Running Tests on CI

```yaml
# Manual trigger with custom devices
gh workflow run integration-tests-browserstack.yml \
  -f devices="Google Pixel 7-13.0,Samsung Galaxy S23-13.0"
```

## Troubleshooting

### Common Issues

**Issue**: Tests timeout
- **Solution**: Increase `testTimeout` in configuration
- Check device availability on BrowserStack

**Issue**: Screenshots not captured
- **Solution**: Ensure `captureScreenshots: true`
- Check disk space on BrowserStack device

**Issue**: App crashes on startup
- **Solution**: Add more verbose logging
- Check logcat output from test run

## Best Practices

1. **Keep tests independent** - Each test should be able to run standalone
2. **Use meaningful test names** - Describe what's being tested
3. **Avoid hard waits** - Use `pumpAndSettle()` instead of `Future.delayed()`
4. **Test user workflows** - Focus on user-facing functionality
5. **Mock external services** - Don't rely on network during tests
6. **Capture failures** - Use screenshots to debug failed tests

## Resources

- [Flutter Integration Testing](https://flutter.dev/docs/testing/integration-tests)
- [BrowserStack Documentation](https://www.browserstack.com/docs/app-automate)
- [Flutter Testing Best Practices](https://flutter.dev/docs/testing)
