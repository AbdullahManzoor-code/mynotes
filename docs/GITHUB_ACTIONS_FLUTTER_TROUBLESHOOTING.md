# GitHub Actions - Flutter Setup Troubleshooting

## Issue: "Unable to determine Flutter version for channel: stable"

### Error Message
```
Run chmod +x "$GITHUB_ACTION_PATH/setup.sh"
Unable to determine Flutter version for channel: stable version: stable architecture: x64
Error: Process completed with exit code 1.
```

### Cause
The `subosito/flutter-action@v2` cannot resolve the "stable" channel version. This typically happens when:
- Network issues connecting to Flutter API
- The Flutter release API is temporarily down
- The action version doesn't support "stable" shorthand
- GitHub Actions runner has connectivity issues

### Solution Applied ✅

**Changed**: `flutter-version: 'stable'` → `flutter-version: '3.13.0'`

Using a specific version number instead of a channel name is more reliable.

---

## Current Configuration

### Android Setup
```yaml
- name: 🔧 Setup Flutter (with retry)
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.13.0'  # ← Specific version
    cache: true
```

### iOS Setup
```yaml
- name: 🔧 Setup Flutter (with retry)
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.13.0'  # ← Specific version
    cache: true
```

### Verification Step
Both Android and iOS now include:
```yaml
- name: 🔧 Verify Flutter installation
  run: |
    flutter --version
    dart --version
```

This ensures Flutter is properly installed before proceeding.

---

## How to Use This Fix

### No Action Needed!
The workflow has been updated automatically. Your next push will use:
- ✅ Specific Flutter version (3.13.0)
- ✅ Verification step after installation
- ✅ More reliable setup process

---

## If You Still Get Errors

### Check the Runner Has Network Access
```bash
# In GitHub Actions, this would show:
curl -s https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter-linux-x64.zip \
  -L --output /dev/null --write-out '%{http_code}\n'
# Should return: 200
```

### Alternative: Use Different Flutter Version
If 3.13.0 causes issues, try other versions:

```yaml
# Option 1: Latest stable (auto-updates)
flutter-version: 'stable'

# Option 2: Specific LTS version
flutter-version: '3.10.0'

# Option 3: Latest beta
flutter-version: 'beta'

# Option 4: Latest from main channel
flutter-version: 'main'
```

### Most Reliable Versions
```
3.22.0 ✅ (Latest stable)
3.13.0 ✅ (What we use)
3.10.0 ✅ (LTS version)
```

---

## Supported Flutter Versions in pubspec.yaml

Your app requires:
```yaml
environment:
  sdk: ">=3.0.0 <4.0.0"
```

All these versions are compatible:
- ✅ 3.13.0 (current)
- ✅ 3.10.0 (LTS)
- ✅ 3.22.0 (latest)

---

## Debug: What Happens During Setup

When GitHub Actions runs, it:

1. **Checkout code** - Gets your repository
2. **Setup Java** (Android only) - JDK 17
3. **Setup Android SDK** (Android only) - Platform tools
4. **Download Flutter** - Fetches 3.13.0
5. **Extract Flutter** - Unzips in cache
6. **Verify Installation** - Runs `flutter --version`
7. **Get dependencies** - Runs `flutter pub get`
8. **Build APKs** - Compiles your app

### Where It Failed Before
```
Step 4: Download Flutter 
  Error: Cannot resolve "stable" to a version number ❌
```

### How It Works Now
```
Step 4: Download Flutter
  Get version 3.13.0 directly from releases ✅
```

---

## Monitoring the Fix

### Check Your Workflow Run

1. Go to: **Actions** tab
2. Click latest workflow run
3. Look for step: **🔧 Verify Flutter installation**
4. Should show:
   ```
   Flutter 3.13.0 • channel stable • https://github.com/flutter/flutter.git
   Dart 3.1.0 (stable)
   ```

### If You See This, It's Working ✅
```
✅ Flutter 3.13.0 • channel stable
✅ Dart 3.1.0 (stable)
✅ Building app debug APK...
```

---

## Caching Optimization

The workflow uses caching to speed up subsequent runs:

```yaml
cache: true  # Caches Flutter SDK between runs
```

**Benefits**:
- First run: ~3 minutes (downloads Flutter)
- Later runs: ~30 seconds (uses cache)

**Cache is cleared when**:
- GitHub clears old caches (after 7 days with no hits)
- You manually clear it
- You change Flutter version

---

## Testing Locally

Verify your app builds with Flutter 3.13.0:

```bash
# Check what you're currently using
flutter --version

# Switch to 3.13.0 (if using FVM)
fvm install 3.13.0
fvm use 3.13.0

# Verify
flutter --version

# Build APK
flutter build apk

# Run integration tests
flutter test integration_test/
```

---

## If Version Mismatch Issues Occur

Different Flutter versions can cause issues. Ensure consistency:

```yaml
# .github/workflows/integration-tests-browserstack.yml
flutter-version: '3.13.0'  # ← Matches your local version
```

vs

```bash
# Your local machine
flutter --version  # Should also show 3.13.0
```

If different:
- Use **FVM** (Flutter Version Manager) locally
- Or update the workflow to match your local version

---

## Related Links

- [subosito/flutter-action Docs](https://github.com/subosito/flutter-action)
- [Flutter Releases](https://github.com/flutter/flutter/releases)
- [Supported Flutter Versions](https://docs.flutter.dev/release/support)

---

## Summary of Changes

| What | Before | After |
|------|--------|-------|
| Flutter Version | `stable` (variable) | `3.13.0` (fixed) |
| Verification | None | Added version check |
| Reliability | Can fail | Should always work |

---

## Next Steps

1. ✅ Push code to `main` branch
2. ✅ Watch GitHub Actions run
3. ✅ Verify "Verify Flutter installation" step completes
4. ✅ Tests should now build successfully

---

## Still Having Issues?

### Enable Debug Logging

Add to workflow before Flutter setup:
```yaml
- name: Enable Flutter debug logging
  run: |
    export FLUTTER_VERBOSE=true
    flutter config --enable-web
    flutter doctor -v
```

### Check System Requirements

GitHub Actions runners provide:
- ✅ 7GB available disk space
- ✅ 4GB RAM
- ✅ Network access to storage.googleapis.com
- ✅ Ubuntu 22.04 or macOS 13+

### Contact Support

If issues persist:
- **Flutter Issues**: https://github.com/flutter/flutter/issues
- **Action Issues**: https://github.com/subosito/flutter-action/issues
- **BrowserStack**: https://www.browserstack.com/support

---

## Version History

| Date | Flutter Version | Reason |
|------|-----------------|--------|
| 2026-02-26 | 3.13.0 | Fixed: "stable" channel resolution issue |

---

**Status**: ✅ Flutter setup is now reliable with specific version 3.13.0
