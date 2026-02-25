# BrowserStack API Quick Reference

This file provides quick reference for common BrowserStack API calls and commands.

## Environment Setup

```bash
# Set credentials as environment variables
export BS_USERNAME="your_browserstack_username"
export BS_API_KEY="your_browserstack_api_key"

# Or for Windows PowerShell
$env:BS_USERNAME = "your_browserstack_username"
$env:BS_API_KEY = "your_browserstack_api_key"
```

## API Endpoints

### Upload App APK
```bash
curl -u "$BS_USERNAME:$BS_API_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/app" \
  -F "file=@android/build/app/outputs/apk/debug/app-debug.apk"
```

**Response:**
```json
{
  "app_name": "app-debug.apk",
  "app_url": "bs://j3c874f21852ea50957a3fdc33f47514288c4ba4",
  "app_id": "j3c874f21852ea50957a3fdc33f47514288c4ba4"
}
```

### Upload Test Suite APK
```bash
curl -u "$BS_USERNAME:$BS_API_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/test-suite" \
  -F "file=@android/build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk"
```

**Response:**
```json
{
  "test_suite_name": "app-debug-androidTest.apk",
  "test_suite_url": "bs://f7c874f21852ba57957a3fde31f47514288c4ba4",
  "test_suite_id": "f7c874f21852ba57957a3fde31f47514288c4ba4",
  "framework": "flutter-integration-tests"
}
```

### Run Integration Tests
```bash
curl -u "$BS_USERNAME:$BS_API_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/build" \
  -d '{
    "app": "bs://j3c874f21852ea50957a3fdc33f47514288c4ba4",
    "testSuite": "bs://f7c874f21852ba57957a3fde31f47514288c4ba4",
    "devices": ["Google Pixel 7-13.0", "Samsung Galaxy S23-13.0"]
  }' \
  -H "Content-Type: application/json"
```

**Response:**
```json
{
  "message": "Success",
  "build_id": "4d2b4deb810af077d5aed98f479bfdd2e64f36c3"
}
```

### Get Build Status
```bash
curl -u "$BS_USERNAME:$BS_API_KEY" \
  "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/builds/4d2b4deb810af077d5aed98f479bfdd2e64f36c3"
```

**Response:**
```json
{
  "build_id": "4d2b4deb810af077d5aed98f479bfdd2e64f36c3",
  "status": "completed",
  "tests_completed": 5,
  "tests_failed": 0,
  "duration": "2m 45s"
}
```

### Get Build Sessions
```bash
curl -u "$BS_USERNAME:$BS_API_KEY" \
  "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/builds/4d2b4deb810af077d5aed98f479bfdd2e64f36c3/sessions"
```

## Supported Devices

### Google Devices
- `Google Pixel 9-15.0`
- `Google Pixel 8-14.0`
- `Google Pixel 7-13.0`
- `Google Pixel 6-12.0`
- `Google Pixel 5-11.0`

### Samsung Devices
- `Samsung Galaxy S24-14.0`
- `Samsung Galaxy S23-13.0`
- `Samsung Galaxy S22-12.0`
- `Samsung Galaxy A51-10.0`

### OnePlus Devices
- `OnePlus 12-14.0`
- `OnePlus 11-13.0`
- `OnePlus 9-11.0`

### Other Manufacturers
- Xiaomi (MI, POCO, Redmi)
- Motorola (Moto)
- Nothing Phone

For complete list: https://www.browserstack.com/app-automate/devices

## Build APKs with Custom Parameters

### With Additional Dart Parameters
```bash
cd android
./gradlew app:assembleDebug \
  -Pdart-defines="ZW52ID0gbm9ucHJvZA==" \
  -Ptarget="../integration_test/app_test.dart"
cd ..
```

### With No Sound Null Safety
```bash
cd android
./gradlew app:assembleDebug -Ptarget="../integration_test/app_test.dart" \
  --no-sound-null-safety
cd ..
```

## Advanced Test Configuration

### Multiple Devices Parallel Execution
```json
{
  "app": "bs://...",
  "testSuite": "bs://...",
  "devices": [
    "Google Pixel 7-13.0",
    "Samsung Galaxy S23-13.0",
    "Google Pixel 6-12.0"
  ]
}
```

### Test with Custom Timeout
```bash
# Maximum test duration is 10 minutes by default
# Can be configured in BrowserStack project settings
```

## PowerShell Examples

### Build both APKs
```powershell
$ErrorActionPreference = "Stop"
Push-Location android
try {
    & ./gradlew app:assembleDebug -Ptarget="../integration_test/app_test.dart"
    & ./gradlew app:assembleAndroidTest
} finally {
    Pop-Location
}
```

### Upload APKs in Parallel
```powershell
$cred = New-Object System.Management.Automation.PSCredential(
    "username", 
    (ConvertTo-SecureString "api_key" -AsPlainText -Force)
)

# Upload app
$app = Invoke-RestMethod -Uri "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/app" `
    -Method Post -Auth Basic -Credential $cred `
    -Form @{file = Get-Item "android/build/app/outputs/apk/debug/app-debug.apk"}

# Upload test suite
$test = Invoke-RestMethod -Uri "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/test-suite" `
    -Method Post -Auth Basic -Credential $cred `
    -Form @{file = Get-Item "android/build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk"}

Write-Host "App URL: $($app.app_url)"
Write-Host "Test Suite URL: $($test.test_suite_url)"
```

## Bash Examples

### Build and Upload with Error Handling
```bash
#!/bin/bash
set -e

# Build
echo "Building APKs..."
pushd android
./gradlew app:assembleDebug -Ptarget="../integration_test/app_test.dart"
./gradlew app:assembleAndroidTest
popd

# Upload
echo "Uploading to BrowserStack..."
app_response=$(curl -u "$BS_USERNAME:$BS_API_KEY" \
    -X POST "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/app" \
    -F "file=@android/build/app/outputs/apk/debug/app-debug.apk")

test_response=$(curl -u "$BS_USERNAME:$BS_API_KEY" \
    -X POST "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/test-suite" \
    -F "file=@android/build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk")

app_url=$(echo $app_response | jq -r '.app_url')
test_url=$(echo $test_response | jq -r '.test_suite_url')

echo "App URL: $app_url"
echo "Test Suite URL: $test_url"
```

## Rate Limiting

BrowserStack API rate limits:
- **Uploads**: 10 requests per second
- **Test execution**: 5 concurrent builds
- **Polling**: Recommended interval is 5-10 seconds

## Common Status Values

- `queued` - Test is queued for execution
- `running` - Test is currently running
- `completed` - Test finished successfully
- `failed` - Test failed
- `timeout` - Test exceeded the time limit

## Error Handling

### 401 Unauthorized
```
Credentials are invalid. Check BS_USERNAME and BS_API_KEY
```

### 413 Payload Too Large
```
APK file is too large. Check file size and verify corruption.
```

### 400 Bad Request
```
Invalid test payload. Check JSON structure and device names.
```

### 429 Too Many Requests
```
Rate limit exceeded. Wait before retrying.
```

## Useful Aliases

```bash
# Upload function
upload_apks() {
    echo "Uploading to BrowserStack..."
    curl -u "$BS_USERNAME:$BS_API_KEY" \
        -X POST "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/app" \
        -F "file=@android/build/app/outputs/apk/debug/app-debug.apk" | jq
}

# Check build status
check_build() {
    curl -u "$BS_USERNAME:$BS_API_KEY" \
        "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/builds/$1" | jq
}
```

## Documentation Links

- [BrowserStack API Docs](https://www.browserstack.com/docs/app-automate/api-reference)
- [Flutter Integration Testing](https://flutter.dev/docs/testing/integration-tests)
- [Supported Devices](https://www.browserstack.com/app-automate/devices)
