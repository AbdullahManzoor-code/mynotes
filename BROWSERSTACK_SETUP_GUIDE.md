# BrowserStack Integration Test Setup Guide for MyNotes

This guide provides step-by-step instructions to set up and run integration tests for the MyNotes Flutter app on BrowserStack App Automate.

## Prerequisites

- BrowserStack Account (free trial or paid plan)
- BrowserStack Username and Access Key
- Android SDK and Gradle installed
- Flutter SDK installed
- Git (for version control)

## Step 1: Get BrowserStack Credentials

1. Sign up for a free trial or purchase a plan at [BrowserStack](https://www.browserstack.com/app-automate)
2. Navigate to your account settings
3. Copy your **Username** and **Access Key**
4. Keep these credentials safe - you'll need them for API requests

## Step 2: Build APK Files

### 2.1 Navigate to Android Directory

```bash
cd android
```

### 2.2 Build App Debug APK

```bash
./gradlew app:assembleDebug -Ptarget="../integration_test/app_test.dart"
```

The app APK will be created at:
```
build/app/outputs/apk/debug/app-debug.apk
```

### 2.3 Build Test APK

```bash
./gradlew app:assembleAndroidTest
```

The test APK will be created at:
```
build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk
```

### 2.4 Return to Project Root

```bash
cd ..
```

## Step 3: Upload APK Files to BrowserStack

### 3.1 Upload App APK

Replace `YOUR_USERNAME` and `YOUR_ACCESS_KEY` with your credentials.

```bash
curl -u "YOUR_USERNAME:YOUR_ACCESS_KEY" \
-X POST "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/app" \
-F "file=@android/build/app/outputs/apk/debug/app-debug.apk"
```

**Expected Response:**
```json
{
    "app_name": "app-debug.apk",
    "app_url": "bs://j3c874f21852ea50957a3fdc33f47514288c4ba4",
    "app_id": "j3c874f21852ea50957a3fdc33f47514288c4ba4",
    "uploaded_at": "2024-02-26 10:00:00 UTC",
    "expiry": "2024-03-27 10:00:00 UTC"
}
```

**Save the `app_url` value** - you'll need it for running tests.

### 3.2 Upload Test APK

```bash
curl -u "YOUR_USERNAME:YOUR_ACCESS_KEY" \
-X POST "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/test-suite" \
-F "file=@android/build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk"
```

**Expected Response:**
```json
{
    "test_suite_name": "app-debug-androidTest.apk",
    "test_suite_url": "bs://f7c874f21852ba57957a3fde31f47514288c4ba4",
    "test_suite_id": "f7c874f21852ba57957a3fde31f47514288c4ba4",
    "uploaded_at": "2024-02-26 10:00:00 UTC",
    "expiry": "2024-03-27 10:00:00 UTC",
    "framework": "flutter-integration-tests"
}
```

**Save the `test_suite_url` value** - you'll need it for running tests.

## Step 4: Run Integration Tests on BrowserStack

Use the app_url and test_suite_url values from the previous step.

```bash
curl -u "YOUR_USERNAME:YOUR_ACCESS_KEY" \
-X POST "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/build" \
-d '{
    "app": "bs://j3c874f21852ea50957a3fdc33f47514288c4ba4",
    "testSuite": "bs://f7c874f21852ba57957a3fde31f47514288c4ba4",
    "devices": ["Google Pixel 7-13.0"]
}' \
-H "Content-Type: application/json"
```

**Expected Response:**
```json
{
    "message": "Success",
    "build_id": "4d2b4deb810af077d5aed98f479bfdd2e64f36c3"
}
```

**Save the `build_id`** - use it to track your test execution.

## Step 5: View Test Results

1. Go to the [BrowserStack App Automate Dashboard](https://app-automate.browserstack.com)
2. Log in with your credentials
3. Look for your build by the build_id
4. View:
   - Test execution status
   - Screenshots and video recordings
   - Device logs
   - Performance metrics

## Supported Devices for BrowserStack

Use any of these device names in your API requests:

**Google Devices:**
- Google Pixel 7-13.0
- Google Pixel 6-12.0
- Google Pixel 5-11.0

**Samsung Devices:**
- Samsung Galaxy S23-13.0
- Samsung Galaxy S22-12.0
- Samsung Galaxy A51-10.0

**OnePlus Devices:**
- OnePlus 11-13.0
- OnePlus 9-11.0

For a complete list, visit: [BrowserStack Supported Devices](https://www.browserstack.com/app-automate/devices)

## Troubleshooting

### Issue: "No Tests Ran"
- **Solution:** Make sure you've successfully built both the app APK and test APK
- Verify MainActivityTest.java is in the correct directory
- Check the build logs for errors

### Issue: "App Upload Failed"
- **Solution:** Check your internet connection
- Verify your credentials are correct
- Ensure the APK file exists at the specified path

### Issue: "Test Execution Timeout"
- **Solution:** Tests timeout after 10 minutes by default
- Ensure your integration tests complete within this timeframe
- Optimize test performance by reducing waits

### Issue: "Device Not Available"
- **Solution:** Check the BrowserStack supported devices list
- Some devices may be in high demand - try a different device
- Check if your app meets the device's Android version requirements

## Running Tests Locally (Development)

While developing, you can run integration tests locally:

```bash
# Run on connected Android device
flutter test integration_test/app_test.dart -d <device-id>

# Or run with specific target
flutter drive --target=integration_test/app_test.dart -d <device-id>
```

## Quick Reference: API Endpoints

### BrowserStack Flutter Integration Test Endpoints

- **Upload App**: `https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/app`
- **Upload Test Suite**: `https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/test-suite`
- **Run Tests**: `https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/build`
- **Get Build Status**: `https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/builds/{build_id}`

## Additional Resources

- [BrowserStack Flutter Integration Testing Docs](https://www.browserstack.com/docs/app-automate/flutter-integration-tests)
- [Flutter Integration Testing Guide](https://flutter.dev/docs/testing/integration-tests)
- [Flutter Test Documentation](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html)

## Next Steps

1. ✅ Set up integration tests locally
2. ✅ Build APK files
3. ✅ Upload to BrowserStack
4. ✅ Run tests on multiple devices
5. ✅ Integrate into CI/CD pipeline (GitHub Actions, etc.)
