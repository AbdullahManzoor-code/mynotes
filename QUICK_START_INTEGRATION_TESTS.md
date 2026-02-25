# 🚀 Integration Testing Quick Start Checklist

Use this checklist to get your integration tests up and running.

## Phase 1: Local Setup (5 minutes)

- [ ] Read [INTEGRATION_TESTING_SETUP_SUMMARY.md](./INTEGRATION_TESTING_SETUP_SUMMARY.md)
- [ ] Verify Flutter and Android SDK are installed
  ```bash
  flutter --version
  flutter doctor -v
  ```
- [ ] Get project dependencies
  ```bash
  flutter pub get
  ```
- [ ] Connect Android device or start emulator
  ```bash
  flutter devices
  ```

## Phase 2: Run Tests Locally (10 minutes)

- [ ] Run basic integration tests
  ```bash
  flutter test integration_test/app_test.dart
  ```
- [ ] Run comprehensive test suite
  ```bash
  flutter test integration_test/app_integration_test.dart
  ```
- [ ] Verify all tests pass ✅
- [ ] Note any failures and fix locally first

## Phase 3: Build APKs (5 minutes)

- [ ] Build app debug APK
  ```bash
  cd android
  ./gradlew app:assembleDebug -Ptarget="../integration_test/app_test.dart"
  ```
- [ ] Verify APK created at:
  ```
  android/build/app/outputs/apk/debug/app-debug.apk
  ```
- [ ] Build test APK
  ```bash
  ./gradlew app:assembleAndroidTest
  ```
- [ ] Verify test APK created at:
  ```
  android/build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk
  ```
- [ ] Return to project root
  ```bash
  cd ..
  ```

## Phase 4: Set Up BrowserStack (5 minutes)

- [ ] Sign up for BrowserStack
  - Visit: https://www.browserstack.com/app-automate
  - Click "Sign Up"
  - Choose a plan (free trial available)

- [ ] Get credentials
  - Log in to BrowserStack
  - Go to Profile → Settings → API Key
  - Copy **Username**
  - Copy **Access Key**

- [ ] Set credentials as environment variables
  
  **Windows PowerShell:**
  ```powershell
  $env:BS_USERNAME = "your_username"
  $env:BS_API_KEY = "your_api_key"
  ```
  
  **Linux/Mac:**
  ```bash
  export BS_USERNAME=your_username
  export BS_API_KEY=your_api_key
  ```

## Phase 5: Upload to BrowserStack (5 minutes)

### Option A: Using Upload Script (Recommended)

**Windows:**
```powershell
./scripts/browserstack_upload.ps1
```

**Linux/Mac:**
```bash
chmod +x scripts/browserstack_upload.sh
./scripts/browserstack_upload.sh
```

### Option B: Manual Upload

See [BROWSERSTACK_SETUP_GUIDE.md](./BROWSERSTACK_SETUP_GUIDE.md) Section 3 for curl commands.

## Phase 6: Run Tests on BrowserStack (5 minutes)

- [ ] Wait for APKs to complete uploading
- [ ] Follow script prompts to select devices
- [ ] Or manually run tests:
  ```bash
  curl -u "$BS_USERNAME:$BS_API_KEY" \
    -X POST "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/build" \
    -d '{"app": "bs://YOUR_APP_URL", "testSuite": "bs://YOUR_TEST_URL", "devices": ["Google Pixel 7-13.0"]}' \
    -H "Content-Type: application/json"
  ```

## Phase 7: View Results (2 minutes)

- [ ] Open BrowserStack Dashboard: https://app-automate.browserstack.com
- [ ] Find your build by Build ID
- [ ] View:
  - [ ] Test status (passed/failed)
  - [ ] Screenshots
  - [ ] Video recording
  - [ ] Device logs
  - [ ] Performance metrics

## Phase 8: CI/CD Setup (Optional, 10 minutes)

- [ ] Go to GitHub repo settings
- [ ] Secrets and variables → Actions
- [ ] Add new secrets:
  - [ ] `BROWSERSTACK_USERNAME`
  - [ ] `BROWSERSTACK_API_KEY`
- [ ] Tests will now run automatically on push to main/develop

## 🎯 Success Criteria

✅ All items checked above  
✅ Local tests passing  
✅ APKs building without errors  
✅ APKs uploading to BrowserStack  
✅ Tests running on BrowserStack  
✅ Test results visible in dashboard  
✅ GitHub Actions workflow configured  

## 📚 Important Documentation

Keep these links handy:

- **Getting Started**: [integration_test/README.md](./integration_test/README.md)
- **Detailed Setup**: [BROWSERSTACK_SETUP_GUIDE.md](./BROWSERSTACK_SETUP_GUIDE.md)
- **API Reference**: [BROWSERSTACK_API_REFERENCE.md](./BROWSERSTACK_API_REFERENCE.md)
- **Configuration**: [integration_test/integration_test_config.md](./integration_test/integration_test_config.md)

## ⚡ Quick Commands

```bash
# Test locally
flutter test integration_test/app_test.dart

# Build APKs
cd android && ./gradlew app:assembleDebug -Ptarget="../integration_test/app_test.dart" && ./gradlew app:assembleAndroidTest && cd ..

# Upload (PowerShell)
./scripts/browserstack_upload.ps1

# Upload (Bash)
./scripts/browserstack_upload.sh

# Verbose testing
flutter test --verbose integration_test/app_test.dart
```

## 🐛 Troubleshooting

| Problem | Solution | More Info |
|---------|----------|-----------|
| Tests fail locally | Run `flutter pub get` | [integration_test/README.md](./integration_test/README.md) |
| APK build fails | Check `android/local.properties` | [BROWSERSTACK_SETUP_GUIDE.md](./BROWSERSTACK_SETUP_GUIDE.md) |
| Upload fails | Check credentials and internet | [BROWSERSTACK_API_REFERENCE.md](./BROWSERSTACK_API_REFERENCE.md) |
| Tests timeout | Device busy, try different device | BrowserStack Dashboard |
| 401 Unauthorized | Invalid credentials | Check BS_USERNAME and BS_API_KEY |

Still stuck? Check [BROWSERSTACK_SETUP_GUIDE.md](./BROWSERSTACK_SETUP_GUIDE.md#troubleshooting)

## 📧 Common Issues

**Q: "No Tests Ran" error**
- A: Verify MainActivityTest.java is at: `android/app/src/androidTest/java/com/abdullahmanzoor/mynotes/MainActivityTest.java`

**Q: APK not found after build**
- A: Check that you're in the correct directory and build completed without errors

**Q: Credentials don't work**
- A: Copy from BrowserStack Account Settings → API Key, not dashboard username/password

**Q: Tests pass locally but fail on BrowserStack**
- A: Check screenshots/video in BrowserStack dashboard for clues, often timing or UI issues

## 🎓 Next Steps After Setup

1. ✅ All tests passing locally
2. ✅ All tests passing on BrowserStack
3. ⏭️ Write additional test scenarios for your app features
4. ⏭️ Configure CI/CD for automated testing
5. ⏭️ Monitor test results in dashboard
6. ⏭️ Expand device testing matrix
7. ⏭️ Set up performance baselines

## 📝 Test Writing Tips

Already have tests running? Add more tests by:

1. Copy test structure from `app_test.dart`
2. Reference `test_utils.dart` for helper functions
3. Use descriptive test names
4. Keep tests independent
5. Follow Flutter best practices

Example:
```dart
testWidgets('My new feature test', (WidgetTester tester) async {
  app.main();
  await IntegrationTestUtils.waitForAppToSettle(tester);
  
  // Your test code here
  
  expect(find.byType(SomeWidget), findsWidgets);
});
```

## ✨ You're All Set!

Your integration testing infrastructure is ready. Start with Phase 1 and work through each phase in order.

**Estimated total time: 30-45 minutes**

Questions? Check the documentation files listed above.

Happy testing! 🚀

---

**Last Updated:** February 2026  
**Status:** Ready to use ✅
