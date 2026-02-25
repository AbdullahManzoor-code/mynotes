# GitHub Actions - BrowserStack Automated Testing Setup

## Overview

Your GitHub Actions workflow is now configured to **automatically run integration tests on BrowserStack** whenever you push code or create a pull request.

**What Happens Automatically**:
1. ✅ Code is pushed to `main` or `develop` branch
2. ✅ GitHub Actions workflow starts automatically
3. ✅ Tests are built (Android & iOS)
4. ✅ Tests are uploaded to BrowserStack
5. ✅ Tests run on real devices
6. ✅ Results are reported back to your PR/commit

---

## Step 1: Get BrowserStack Credentials

### From BrowserStack Website

1. Go to: **https://app.browserstack.com/accounts/profile**
2. Find these values:
   - **Username**: Your email address (e.g., `your_email@example.com`)
   - **Access Key**: Click "Show" button next to your username
3. **Copy both values** - you'll need them next

---

## Step 2: Add GitHub Secrets

### Add BROWSERSTACK_USERNAME

1. Go to your GitHub repository: **https://github.com/AbdullahManzoor-code/mynotes**
2. Click **⚙️ Settings** (top right)
3. Click **Secrets and variables** → **Actions** (left sidebar)
4. Click **New repository secret** (green button)
5. **Name**: `BROWSERSTACK_USERNAME`
6. **Value**: Your BrowserStack email/username (e.g., `your_email@example.com`)
7. Click **Add secret**

### Add BROWSERSTACK_API_KEY

1. Click **New repository secret** again
2. **Name**: `BROWSERSTACK_API_KEY`
3. **Value**: Your BrowserStack Access Key (from Step 1)
4. Click **Add secret**

---

## Step 3: Verify Secrets Are Set

```
✅ Settings → Secrets and variables → Actions
   ├─ BROWSERSTACK_USERNAME
   └─ BROWSERSTACK_API_KEY
```

Both should appear in the list with a **green checkmark**.

---

## Now Automatic Testing Works!

### When Tests Run Automatically

**Trigger Events**:
- ✅ Push to `main` branch
- ✅ Push to `develop` branch
- ✅ Create/update Pull Request
- ✅ Manually via "Run workflow" button

### Monitor Test Execution

1. Go to **https://github.com/AbdullahManzoor-code/mynotes/actions**
2. Click the latest workflow run
3. Watch the progress:
   - 🔨 Building APKs/iOS packages
   - 📤 Uploading to BrowserStack
   - 🚀 Running tests (with polling)
   - 📊 Viewing results

---

## Workflow Details

### Android Tests

```
Step 1: Build APK
  ↓
Step 2: Build Test APK
  ↓
Step 3: Upload to BrowserStack
  ↓
Step 4: Run on Google Pixel 7-13.0
  ↓
Step 5: Poll for results (up to 20 minutes)
  ↓
Step 6: Report results
```

### iOS Tests (macOS)

```
Step 1: Build iOS test package
  ↓
Step 2: Create ZIP file
  ↓
Step 3: Upload to BrowserStack
  ↓
Step 4: Run on iPhone 14-17.4
  ↓
Step 5: Poll for results (up to 20 minutes)
  ↓
Step 6: Report results
```

---

## Viewing Test Results

### After Workflow Completes

1. Go to **https://app-automate.browserstack.com**
2. Log in with BrowserStack credentials
3. Find your test build (shows Build ID from workflow)
4. View:
   - ✅ Pass/Fail status
   - 🎥 Video recordings
   - 📸 Screenshots
   - 📊 Device logs
   - 🔍 Test details

---

## Customize Devices (Optional)

### Change Default Devices

Edit `.github/workflows/integration-tests-browserstack.yml` and modify the `devices:` input:

```yaml
workflow_dispatch:
  inputs:
    devices:
      description: 'Devices to test on (comma-separated)'
      required: false
      default: 'Google Pixel 7-13.0,iPhone 14-17.4'  # ← Change these
```

### Available Android Devices
```
Google Pixel 7-13.0
Google Pixel 6-12.0
Samsung Galaxy S23-13.0
OnePlus 11-13.0
```

### Available iOS Devices
```
iPhone 14-17.4
iPhone 13-16.5
iPad Pro 12.9-17.4
```

---

## Manual Workflow Trigger

### Run Tests Manually

1. Go to **Actions** tab
2. Select **"Integration Tests - BrowserStack (Android & iOS)"**
3. Click **"Run workflow"** (blue button)
4. (Optional) Customize:
   - **Platforms**: `android,ios` or just one
   - **Devices**: Custom device list
5. Click **"Run workflow"** button

---

## Troubleshooting

### Build fails with "BROWSERSTACK_USERNAME not found"

**Solution**: Secrets not set properly
- Go to **Settings → Secrets → Actions**
- Verify both secrets exist and match exactly:
  - `BROWSERSTACK_USERNAME` (note uppercase)
  - `BROWSERSTACK_API_KEY` (note uppercase)

### Tests timeout after 20 minutes

**Why**: Long-running tests may take longer than timeout
- Increase `max_attempts` in workflow file (currently 120 = 20 minutes)
- Or reduce number of test cases

### Workflow shows "Upload failed"

**Why**: Invalid BrowserStack credentials
- Verify credentials at https://app.browserstack.com/accounts/profile
- Update secrets in GitHub
- Re-run workflow

### APK build fails

**Causes**:
- Missing Flutter dependencies
- Incompatible Gradle version
- Java version mismatch

**Solution**:
```bash
# Run locally first to verify it works
flutter clean
flutter pub get
cd android
./gradlew app:assembleDebug
cd ..
```

---

## What Gets Cached

The workflow uses caching to speed up builds:

```yaml
cache: true
```

This caches:
- ✅ Flutter SDK
- ✅ Gradle dependencies
- ✅ Android SDK components
- ✅ iOS CocoaPods

**Cache is automatically invalidated when**:
- `pubspec.yaml` changes
- `build.gradle.kts` changes
- `Podfile` changes

---

## Environment Variables Used

| Variable | Source | Used For |
|----------|--------|----------|
| `BROWSERSTACK_USERNAME` | GitHub Secrets | BrowserStack authentication |
| `BROWSERSTACK_API_KEY` | GitHub Secrets | BrowserStack API calls |
| `FLUTTER_VERSION` | Workflow | Flutter SDK version (stable) |
| `JAVA_VERSION` | Workflow | Java for Android build (17) |
| `ANDROID_API` | Workflow | Android API level (34) |

---

## Security Notes

✅ **Secrets are protected**:
- Never logged to console output
- Only used in authenticated API calls
- Not visible in workflow logs
- Encrypted in GitHub

---

## Next Steps

1. ✅ Set GitHub Secrets (BROWSERSTACK_USERNAME and BROWSERSTACK_API_KEY)
2. ✅ Push a commit to `main` branch
3. ✅ Go to **Actions** tab
4. ✅ Watch the workflow run
5. ✅ Check BrowserStack dashboard for results

---

## API Endpoints Used

### Android
- **Upload App**: `POST /app-automate/flutter-integration-tests/v2/android/app`
- **Upload Tests**: `POST /app-automate/flutter-integration-tests/v2/android/test-suite`
- **Run Tests**: `POST /app-automate/flutter-integration-tests/v2/android/build`
- **Get Results**: `GET /app-automate/flutter-integration-tests/v2/android/builds/{build_id}`

### iOS
- **Upload Package**: `POST /app-automate/flutter-integration-tests/v2/ios/test-package`
- **Run Tests**: `POST /app-automate/flutter-integration-tests/v2/ios/build`
- **Get Results**: `GET /app-automate/flutter-integration-tests/v2/ios/builds/{build_id}`

---

## Workflow File

See: [.github/workflows/integration-tests-browserstack.yml](.github/workflows/integration-tests-browserstack.yml)

**Key Features**:
- ✅ Parallel Android & iOS testing
- ✅ Automatic result polling (20 min timeout)
- ✅ Error handling with exit codes
- ✅ Detailed logging
- ✅ GitHub PR status integration

---

## Support

- **BrowserStack Docs**: https://www.browserstack.com/app-automate/flutter
- **GitHub Actions Docs**: https://docs.github.com/en/actions
- **Flutter Testing**: https://flutter.dev/docs/testing

---

## Quick Checklist

- [ ] Get BrowserStack credentials from https://app.browserstack.com/accounts/profile
- [ ] Add `BROWSERSTACK_USERNAME` secret to GitHub
- [ ] Add `BROWSERSTACK_API_KEY` secret to GitHub
- [ ] Push a commit to `main` branch
- [ ] Go to Actions tab and verify workflow runs
- [ ] Check BrowserStack dashboard for results
- [ ] All tests pass! ✨

---

**Status**: ✅ GitHub Actions fully configured and ready to automate BrowserStack testing!
