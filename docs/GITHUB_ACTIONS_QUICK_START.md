# Quick Start - GitHub Actions Integration Testing

## ⚡ 3-Minute Setup

### Step 1: Add GitHub Secrets (2 minutes)

Go to: **GitHub Repo → Settings → Secrets and variables → Actions → New repository secret**

Add two secrets:

```
Name: BROWSERSTACK_USERNAME
Value: your_email@example.com  (from https://app.browserstack.com/accounts/profile)

Name: BROWSERSTACK_API_KEY
Value: your_access_key (from https://app.browserstack.com/accounts/profile)
```

---

### Step 2: Push Code (automatic)

```bash
git push origin main
```

✅ Workflow starts automatically!

---

### Step 3: View Results

Go to: **https://github.com/AbdullahManzoor-code/mynotes/actions**

Click the latest run and watch tests execute.

---

## What Happens Next

### Timeline

```
⏱️ 0:00  - You push code
⏱️ 0:30  - Workflow starts
⏱️ 1:00  - Android: Build APKs
⏱️ 2:00  - iOS: Build test package
⏱️ 2:30  - Upload to BrowserStack
⏱️ 3:00  - Tests start running
⏱️ 3:30  - Polling for results (every 10 sec)
⏱️ 5:00  - Tests complete ✅
```

**Total time**: 5-30 minutes (depending on test complexity)

---

## View Test Results

### On GitHub Actions

1. Click the workflow run
2. Expand each job (Android/iOS)
3. View logs and outputs
4. Click links to BrowserStack dashboard

### On BrowserStack Dashboard

1. Go to: **https://app-automate.browserstack.com**
2. Find your build by Build ID
3. View:
   - ✅ Pass/Fail status
   - 🎥 Video of test execution
   - 📸 Screenshots at each step
   - 📊 Device logs
   - 🔍 Full test details

---

## Trigger Tests Manually

### Via GitHub UI

1. **Actions** tab
2. **Integration Tests - BrowserStack**
3. **Run workflow** button (blue)
4. (Optional) Customize platforms/devices
5. **Run workflow**

### Via GitHub CLI

```bash
gh workflow run integration-tests-browserstack.yml \
  -f platforms=android,ios \
  -f devices="Google Pixel 7-13.0,iPhone 14-17.4"
```

---

## Monitor Progress

### In GitHub Actions Tab

Watch these steps complete:

#### Android Job
```
✅ Checkout code
✅ Setup Java
✅ Setup Android SDK
✅ Setup Flutter
✅ Get Flutter dependencies
✅ Build app debug APK
✅ Build test APK
✅ Upload app APK to BrowserStack
✅ Upload test APK to BrowserStack
✅ Run Android integration tests
✅ Poll for results
✅ Generate Android test report
```

#### iOS Job
```
✅ Checkout code
✅ Setup Flutter
✅ Get Flutter dependencies
✅ Build iOS test package
✅ Create iOS test package zip
✅ Upload iOS test package
✅ Run iOS integration tests
✅ Poll for results
✅ Generate iOS test report
```

---

## Understanding the Output

### Successful Build

```
✅ Android App uploaded: bs://1a2b3c4d5e6f
✅ Android Test Suite uploaded: bs://0z9y8x7w6v5u
✅ Android Tests started with build ID: 741c219db523cb51d4cdf35723ce3bfc592fb74a

🔄 Polling for test results...
⏳ Attempt 1/120 - Status: started
⏳ Attempt 5/120 - Status: running
⏳ Attempt 30/120 - Status: running
✅ Tests completed with status: completed

📊 Full test results available at: https://app-automate.browserstack.com
```

### Failed Upload

```
❌ Failed to upload app APK
Response: {"error": "Invalid credentials"}
```

**Fix**: Verify GitHub secrets are correct

---

## Common Actions

### Check Recent Runs
```bash
gh run list --repo AbdullahManzoor-code/mynotes --limit 10
```

### View Latest Run Status
```bash
gh run view --repo AbdullahManzoor-code/mynotes --log
```

### Download Logs
```bash
gh run download --repo AbdullahManzoor-code/mynotes <run_id>
```

---

## Device Selection

### Default Devices

The workflow tests on:
- **Android**: Google Pixel 7-13.0
- **iOS**: iPhone 14-17.4

### Change Devices

When manually running workflow:

1. Click **Run workflow** button
2. Enter **Devices**: `Google Pixel 6-12.0,Samsung Galaxy S23-13.0,iPhone 14-17.4`
3. Click **Run workflow**

### Available Options

**Android**:
- Google Pixel 7-13.0
- Google Pixel 6-12.0
- Samsung Galaxy S23-13.0
- OnePlus 11-13.0

**iOS**:
- iPhone 14-17.4
- iPhone 13-16.5
- iPad Pro 12.9-17.4

---

## Troubleshooting

### Workflow Won't Start

**Check**:
1. Code pushed to `main` or `develop` branch
2. GitHub Actions enabled in repository settings
3. Secrets are set with correct names (case-sensitive)

### Tests Timeout

**Status**: Workflow still waiting for test results

**Solution**: 
- Tests normally take 5-30 minutes
- Max wait is 20 minutes before timeout
- Check BrowserStack dashboard to see actual test status

### Upload Fails with 401/403

**Cause**: Invalid BrowserStack credentials

**Fix**:
1. Verify at: https://app.browserstack.com/accounts/profile
2. Update GitHub secrets
3. Re-run workflow

### APK/Package Build Fails

**Check**:
1. Code compiles locally: `flutter build apk`
2. iOS builds: `cd ios && xcodebuild`
3. All dependencies installed: `flutter pub get`

---

## Monitoring Checklist

- [ ] Secrets are set in GitHub
- [ ] Code is pushed to main/develop
- [ ] Workflow appears in Actions tab
- [ ] Android and iOS jobs start
- [ ] Tests upload to BrowserStack
- [ ] Polling begins for results
- [ ] Results appear in BrowserStack dashboard
- [ ] Workflow completes (success or failure)
- [ ] Pull request shows test status ✅

---

## Performance Tips

### Speed Up Tests

1. **Run Android only** (faster):
   - Set `platforms: android`
   
2. **Test fewer devices**:
   - Use 1-2 devices instead of many
   
3. **Optimize test code**:
   - Remove unnecessary `wait()` calls
   - Parallel test execution where possible

4. **Use caching**:
   - Already enabled in workflow
   - Reuses Flutter SDK between runs

---

## Cost Optimization

### BrowserStack Billing

Tests are billed per **minutes used** on devices.

**Reduce costs**:
- Run tests only on `main` branch (not every PR)
- Test on 1-2 representative devices
- Optimize test duration (shorter tests = lower cost)
- Use parallel execution efficiently

### To Limit to Main Branch Only

Edit `.github/workflows/integration-tests-browserstack.yml`:

```yaml
on:
  push:
    branches: [ main ]  # Only main, not develop
  pull_request:
    branches: [ main ]  # Only PRs to main
```

---

## View Full Workflow File

Location: [.github/workflows/integration-tests-browserstack.yml](.github/workflows/integration-tests-browserstack.yml)

**Contains**:
- ✅ Setup steps
- ✅ Build steps
- ✅ Upload steps
- ✅ Test execution
- ✅ Result polling
- ✅ Reporting

---

## That's It! 🎉

Your CI/CD pipeline is now fully automated:

1. ✅ Push code → 
2. ✅ Workflow triggers → 
3. ✅ Tests build → 
4. ✅ Tests upload → 
5. ✅ Tests run on BrowserStack → 
6. ✅ Results appear 

**No manual action needed!**

---

## Support

- **Need help?** Check: [GITHUB_ACTIONS_BROWSERSTACK_SETUP.md](GITHUB_ACTIONS_BROWSERSTACK_SETUP.md)
- **Questions?** BrowserStack: https://www.browserstack.com/support
- **API Docs**: https://www.browserstack.com/docs/app-automate/api-reference
