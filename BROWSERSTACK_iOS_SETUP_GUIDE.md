# iOS Integration Testing Setup Guide - BrowserStack

This guide provides step-by-step instructions to set up and run Flutter integration tests for iOS on BrowserStack App Automate.

## Prerequisites

- macOS with Xcode 13.0 or later installed
- iOS deployment target 15.5 or higher
- BrowserStack Account (free trial or paid plan)
- BrowserStack Username and Access Key
- Flutter SDK installed
- CocoaPods installed

## Step 1: Verify Xcode Setup

Ensure Xcode is properly installed:

```bash
xcode-select --install
```

Verify Flutter can find Xcode:

```bash
flutter doctor -v
```

You should see:
```
[✓] Xcode - develop for iOS and macOS
[✓] CocoaPods
```

## Step 2: Get BrowserStack Credentials

1. Sign up for a free trial or purchase a plan at [BrowserStack](https://www.browserstack.com/app-automate)
2. Log in to your account
3. Navigate to Account Settings → API Key
4. Copy your **Username** and **Access Key**

## Step 3: Set Up iOS Testing Infrastructure

### 3.1 Update the Podfile

The Podfile has been automatically updated to include the `RunnerTests` target:

```ruby
target 'Runner' do
  # ... existing configuration ...
  
  target 'RunnerTests' do
    inherit! :search_paths
  end
end
```

To manually add if needed, edit `ios/Podfile` and add the RunnerTests target:

```ruby
target 'Runner' do
  # Existing Flutter configuration
  
  target 'RunnerTests' do
    inherit! :search_paths
  end
end
```

### 3.2 Add Test Runner File

The test runner file `ios/RunnerTests/RunnerTests.m` has been created:

```objc
#import <XCTest/XCTest.h>
#import <integration_test/IntegrationTestPlugin.h>

INTEGRATION_TEST_IOS_RUNNER(RunnerTests)
```

This file acts as the entry point for integration tests.

## Step 4: Build iOS Test Package

### Using the Build Script (Recommended)

**macOS/Linux:**
```bash
chmod +x scripts/build_ios_tests.sh
./scripts/build_ios_tests.sh
```

**Windows (PowerShell):**
```powershell
.\scripts\build_ios_tests.ps1
```

### Manual Build

If you prefer to build manually:

```bash
# Navigate to iOS folder
cd ios

# Build for testing
xcodebuild \
  -workspace Runner.xcworkspace \
  -scheme Runner \
  -config Flutter/Release.xcconfig \
  -derivedDataPath ../build/ios_integration \
  -sdk iphoneos \
  build-for-testing

# Return to project root
cd ..
```

### Verify Build Output

After building, check for the test package:

```bash
# Find the xctestrun file
find build/ios_integration/Build/Products -name "*.xctestrun"

# Find Release-iphoneos folder
find build/ios_integration/Build/Products -type d -name "Release-iphoneos"
```

## Step 5: Create Test Package Zip

The build script automatically creates the zip file. If building manually:

```bash
cd build/ios_integration/Build/Products

# Replace <xctestrun_filename> with the actual filename
zip -r "ios_test_package.zip" "Release-iphoneos" "<xctestrun_filename>.xctestrun"

cd ../../../..
```

The zip file should contain:
- `Release-iphoneos/` directory
- `*.xctestrun` file

## Step 6: Upload to BrowserStack

### Using the Upload Script (Recommended)

Set your credentials:

```bash
export BS_USERNAME=your_browserstack_username
export BS_API_KEY=your_browserstack_api_key
```

Run the upload script:

**macOS/Linux:**
```bash
chmod +x scripts/browserstack_upload_ios.sh
./scripts/browserstack_upload_ios.sh
```

**Windows (PowerShell):**
```powershell
$env:BS_USERNAME = "your_username"
$env:BS_API_KEY = "your_api_key"
.\scripts\browserstack_upload_ios.ps1
```

### Manual Upload

Upload test package:

```bash
curl -u "your_username:your_api_key" \
-X POST "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/ios/test-package" \
-F "file=@build/ios_integration/Build/Products/ios_test_package.zip"
```

**Save the `test_package_url`** from response - you'll need it to run tests.

## Step 7: Run Tests on BrowserStack

The upload script can run tests automatically. Or run manually:

```bash
curl -u "your_username:your_api_key" \
-X POST "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/ios/build" \
-d '{
  "testPackage": "bs://3f8ca850476a7c26d4698225e32b353c83cac7ed",
  "devices": ["iPhone 14-17.4"],
  "networkLogs": "true",
  "deviceLogs": "true"
}' \
-H "Content-Type: application/json"
```

Replace `bs://...` with your actual test package URL.

**Save the `build_id`** from response to track your test.

## Step 8: View Test Results

1. Go to [BrowserStack Dashboard](https://app-automate.browserstack.com)
2. Log in with your credentials
3. Find your build by the build_id
4. View:
   - Test execution status
   - Screenshots and video recordings
   - Device logs
   - Performance metrics
   - Network logs

## Supported iOS Devices

### Popular iPhone Models
- iPhone 14 Pro Max (iOS 17.4)
- iPhone 14 Pro (iOS 17.4)
- iPhone 14 (iOS 17.4)
- iPhone 13 Pro Max (iOS 16.5)
- iPhone 13 (iOS 16.5)
- iPhone 12 (iOS 15.5)

### Popular iPad Models
- iPad Pro 12.9 (iOS 17.4)
- iPad Pro 11 (iOS 17.4)
- iPad Air (iOS 16.5)
- iPad (iOS 16.5)

For complete list: https://www.browserstack.com/app-automate/devices

## Troubleshooting

### Issue: "xcodebuild: command not found"
**Solution**: 
```bash
xcode-select --install
# or accept Xcode license
sudo xcode-select --reset
```

### Issue: "RunnerTests target not found"
**Solution**: 
- Verify the Podfile includes the RunnerTests target
- Run `pod install` in the ios directory
- Rebuild the package

### Issue: "xctestrun file not found"
**Solution**:
- Verify the build completed successfully
- Check the build output directory exists
- Ensure you're in the correct directory structure

### Issue: "Upload fails with 413 Payload Too Large"
**Solution**:
- Check zip file size
- Remove unnecessary files from the zip
- Ensure only Release-iphoneos and xctestrun are included

### Issue: "Tests don't run or timeout"
**Solution**:
- Check device availability on BrowserStack
- Verify test package integrity
- Check BrowserStack device logs for errors
- Increase timeout if needed

## Performance Thresholds

| Metric | Target |
|--------|--------|
| Build time | < 10 minutes |
| Test execution | < 15 minutes |
| App launch | < 5 seconds |
| Navigation | < 2 seconds |

## Security Notes

⚠️ **Important**:
- Never commit credentials to git
- Use environment variables for credentials
- Rotate API keys periodically
- Use GitHub Secrets for CI/CD

## CI/CD Integration

The GitHub Actions workflow supports iOS testing. For setup details, see the main CI/CD documentation.

## API Reference

### Upload Test Package
```
POST https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/ios/test-package
```

### Run Tests
```
POST https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/ios/build
```

### Get Build Status
```
GET https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/ios/builds/{build_id}
```

## Quick Commands Reference

```bash
# Build test package
./scripts/build_ios_tests.sh

# Upload and run tests
./scripts/browserstack_upload_ios.sh

# Manual build
cd ios && xcodebuild -workspace Runner.xcworkspace -scheme Runner -config Flutter/Release.xcconfig -derivedDataPath ../build/ios_integration -sdk iphoneos build-for-testing && cd ..

# Check for xctestrun file
find build/ios_integration -name "*.xctestrun"
```

## Additional Resources

- [Flutter iOS Integration Testing](https://flutter.dev/docs/testing/integration-tests)
- [BrowserStack iOS Testing Docs](https://www.browserstack.com/docs/app-automate/flutter-integration-tests/ios)
- [Xcode Build Documentation](https://developer.apple.com/documentation/xcode/)
- [CocoaPods Documentation](https://cocoapods.org/)

---

**Status**: Production Ready ✅  
**Last Updated**: February 2026
