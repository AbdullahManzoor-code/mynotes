# Integration Testing - Troubleshooting & Common Issues

## Quick Reference

| Issue | Symptom | Solution |
|-------|---------|----------|
| Deprecated TestWindow | "Missing selector" errors | Use modern WidgetTester methods |
| Test won't settle | Infinite animations | Check for continuous AnimationControllers |
| Widget not found | "Finder matched 0 widgets" | Use correct Finder or check if widget exists |
| Text not found | Text visible but not found | Use `find.text('exact')` or semantic labels |
| Test hangs | Never completes | Increase timeout or check infinite loops |
| Screenshot fails | "Cannot capture screenshot" | BrowserStack handles this automatically |
| APK fails to upload | "404 not found" | Verify BrowserStack credentials |
| iOS build fails | "Integration test plugin not found" | Run `flutter pub get` and check Podfile |

---

## Common Errors & Solutions

### 1. ERROR: "Missing selector such as '.identifier' or '[0]'"

**What it means**: You're using deprecated TestWindow API to access window properties

**Typical code**:
```dart
// ❌ DEPRECATED - Will cause "Missing selector" error
tester.binding.window.physicalSizeTestValue = Size(1080, 1920);
addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
```

**Solution**:
```dart
// ✅ CORRECT - Use modern APIs
// Let the testing framework handle window sizing
// If you need specific sizes, use `tester.binding.window.physicalSize` read-only

// For testing different sizes, use device emulator settings instead
```

**Why it changed**: Flutter moved away from manual window manipulation in tests to avoid race conditions and ensure consistent test behavior.

---

### 2. ERROR: "Illegal assignment to non-assignable expression"

**What it means**: You're trying to assign to a property that's read-only

**Typical code**:
```dart
// ❌ WRONG - window is read-only in new Flutter
tester.binding.window = myCustomWindow;
```

**Solution**:
```dart
// ✅ CORRECT - Access window properties correctly
final size = tester.binding.window.physicalSize; // Read-only, OK
// Don't try to reassign window itself
```

---

### 3. ERROR: "Timeout waiting for settlement"

**What it means**: `waitForAppToSettle()` timed out (30 seconds by default)

**Causes**:
- Infinite animations running
- Continuous AnimationController without proper cleanup
- Image loading that never completes
- Network requests that timeout

**Solution**:

```dart
// 1. Check for infinite animations
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    // ❌ BAD - Infinite animation
    // _controller.repeat(); // Never stops!

    // ✅ GOOD - Controlled animation
    _controller.forward(); // Plays once
  }

  @override
  void dispose() {
    _controller.dispose(); // Always cleanup!
    super.dispose();
  }
}

// 2. Set longer timeout if needed
await tester.pumpAndSettle(
  const Duration(seconds: 60), // Extend timeout
);

// 3. Use polling instead of waiting for complete settlement
await tester.pump(const Duration(milliseconds: 500));
// Check if your condition is met
if (find.byType(MyWidget).evaluate().isNotEmpty) {
  // Continue test
}
```

---

### 4. ERROR: "Finder matched 0 widgets"

**Meaning**: The widget you're looking for doesn't exist

**Debug steps**:

```dart
// 1. Check what matches
final finder = find.byType(MyCustomWidget);
expect(
  finder,
  findsWidgets,  // Will show all matched widgets
  reason: 'Check the debug output above',
);

// 2. Try printing widget tree
debugPrintWidgetTree(tester);

// 3. Use more specific finder
// Instead of:
find.text('Button') // Might match multiple

// Use:
find.byKey(ValueKey('unique_button'))
find.byType(ElevatedButton).first
find.byWidget(mySpecificButton)

// 4. Ensure widget is built
await IntegrationTestUtils.waitForAppToSettle(tester);
// Now try finder again

// 5. Check conditional rendering
if (showButton) {  // Maybe this is false?
  ElevatedButton(...)
}
```

---

### 5. ERROR: "Text '...' not found"

**Meaning**: Text exists visually but test can't find it

**Causes**:
- Text is in a different widget type (e.g., Tooltip, Semantics label)
- Extra whitespace or special characters
- Text is truncated or styled in a way that affects finding

**Solution**:

```dart
// 1. Use exact text match
IntegrationTestUtils.verifyText('Exact Text');  // Exact match required

// 2. For partial text, use different approach
expect(
  find.text('Exact Text'),
  findsWidgets,
);

// 3. For labels and accessibility text
find.bySemanticsLabel('Button Label')

// 4. For text with special characters, escape properly
IntegrationTestUtils.verifyText('User\'s Name'); // Escaped quote

// 5. Check for case sensitivity
// 'Hello' ≠ 'hello'
final text = 'Hello World';
expect(find.text(text), findsOneWidget);

// 6. Use contains for partial matching
final finder = find.byWidgetPredicate(
  (widget) => widget is Text && widget.data?.contains('partial') == true,
);
```

---

### 6. ERROR: "Test hangs indefinitely"

**Meaning**: Test starts but never completes

**Common causes**:
- Infinite loop in test code
- Waiting for event that never fires
- Deadlock in async operations
- Network request with no timeout

**Debugging**:

```dart
// 1. Add debugging statement
testWidgets('My test', (tester) async {
  print('TEST: Starting test');
  app.main();
  print('TEST: App launched');
  
  await IntegrationTestUtils.waitForAppToSettle(tester);
  print('TEST: App settled');
  
  // If you see this print, test reached this point
  // If you don't, it hangs before this
});

// 2. Use timeout
testWidgets(
  'My test',
  (tester) async {
    // test code
  },
  timeout: Timeout(Duration(seconds: 30)), // Force timeout
);

// 3. Check for infinite loops
// ❌ BAD
while (true) {
  await tester.pump();
}

// ✅ GOOD
for (int i = 0; i < 10; i++) {
  await tester.pump();
}

// 4. Ensure network operations have timeouts
final response = await http.get(uri).timeout(
  Duration(seconds: 10),
  onTimeout: () => throw TimeoutException('Request timed out'),
);
```

---

### 7. ERROR: "Failed to build iOS test runner"

**Meaning**: iOS test compilation failed

**Common causes**:
- Pod dependencies not installed
- Incompatible Swift version
- Missing integration_test plugin

**Solutions**:

```bash
# 1. Clean and reinstall pods
cd ios
rm -rf Pods
rm Podfile.lock
flutter pub get
cd ..
cd ios
pod install
cd ..

# 2. Clean Flutter build
flutter clean
flutter pub get

# 3. Check Podfile has RunnerTests target
# In ios/Podfile, search for:
# target 'RunnerTests' do
#   inherit! :search_paths
#   pod 'integration_test', :path => File.join(packages_dir, 'integration_test/ios')
# end

# 4. Update CocoaPods
sudo gem install cocoapods
pod repo update

# 5. Rebuild
flutter build ios --config-only
```

---

### 8. ERROR: "Android test compilation fails"

**Meaning**: Gradle build fails for test code

**Common causes**:
- Missing test dependencies in build.gradle
- Incorrect Java version
- AndroidX incompatibility

**Solutions**:

```bash
# 1. Clean and rebuild
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get

# 2. Verify build.gradle.kts has:
# testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
# 
# dependencies {
#   testImplementation 'junit:junit:4.13.2'
#   androidTestImplementation 'androidx.test:runner:1.5.2'
#   androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'
#   androidTestImplementation 'androidx.test:rules:1.5.0'
# }

# 3. Update Java version if needed
# Check gradle/wrapper/gradle-wrapper.properties for correct version

# 4. Build APKs
cd android
./gradlew app:assembleDebug
./gradlew app:assembleAndroidTest
cd ..
```

---

### 9. ERROR: "BrowserStack upload fails with 404"

**Meaning**: API endpoint returns "not found"

**Causes**:
- Wrong BrowserStack URL
- Invalid credentials
- Typo in endpoint
- Wrong HTTP method

**Solution**:

```bash
# 1. Verify credentials
echo "Username: $BS_USERNAME"
echo "API Key: ${BS_API_KEY:0:4}****"

# 2. Test credentials manually
curl -u "$BS_USERNAME:$BS_API_KEY" \
  https://api.browserstack.com/app-automate/upload \
  -F "file=@/path/to/app.apk"

# 3. Verify endpoints
# Android APK: https://api.browserstack.com/app-automate/upload
# iOS IPA: https://api.browserstack.com/app-automate/upload
# Both use same endpoint

# 4. Check for typos in build path
# Should be: app-debug.apk, not app_debug.apk
# Should be: app-debug-androidTest.apk
ls -la android/app/build/outputs/apk/debug/

# 5. Verify file exists and is readable
file c:\Users\Mian\mynotes\android\app\build\outputs\apk\debug\app-debug.apk
```

---

### 10. ERROR: "Script execution denied on Windows"

**Meaning**: PowerShell won't run the script

**Solution**:

```powershell
# 1. Check execution policy
Get-ExecutionPolicy -List

# 2. If it says "Restricted", allow scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# OR temporarily for one script:
powershell -ExecutionPolicy Bypass -File scripts/browserstack_upload.ps1

# 3. Run script with proper arguments
cd c:\Users\Mian\mynotes
$env:BS_USERNAME = "your_username"
$env:BS_API_KEY = "your_key"
.\scripts\browserstack_upload.ps1

# 4. Verify script is in correct location
Test-Path "scripts/browserstack_upload.ps1"
```

---

### 11. ERROR: "Emulator/Device not found"

**Meaning**: No Android device or iOS simulator available

**Solution**:

```bash
# 1. For Android - list devices
adb devices

# 2. Start Android emulator if needed
emulator -avd Pixel_4_API_30 &

# 3. For iOS - list simulators
xcrun simctl list devices available

# 4. Start iOS simulator if needed
open -a Simulator
xcrun simctl boot "iPhone 14"

# 5. Verify device is ready
# Android
adb shell getprop ro.build.version.release

# iOS
xcrun simctl status_bar "iPhone 14" override --time "9:41"
```

---

### 12. ERROR: "Dart analysis shows null safety errors"

**Meaning**: Null safety analysis finds issues

**Solution**:

```dart
// Update your test to use null-safe patterns

// ❌ Old code
final element = find.byType(MyWidget).first;
element.evaluate(); // May be null!

// ✅ Null-safe code
final finder = find.byType(MyWidget);
expect(finder, findsOneWidget);
final element = finder.first;

// ✅ With null checks
if (finder.evaluate().isNotEmpty) {
  final element = finder.first;
  // Safe to use element
}

// Update pubspec.yaml
environment:
  sdk: '>=3.0.0 <4.0.0'  # Or appropriate version
```

---

## Performance Issues

### Tests running too slowly

**Diagnosis**:

```dart
testWidgets('Slow test', (tester) async {
  final stopwatch = Stopwatch()..start();

  app.main();
  await IntegrationTestUtils.waitForAppToSettle(tester);
  print('Setup time: ${stopwatch.elapsed.inMilliseconds}ms');

  // ... test operations ...
  print('Operation time: ${stopwatch.elapsed.inMilliseconds}ms');
});
```

**Optimization**:

1. **Reduce settlement wait time**: Only wait when necessary
2. **Use shorter animations**: Disable animations in test mode
3. **Minimize network calls**: Mock APIs when possible
4. **Parallel test execution**: Run multiple tests simultaneously
5. **Profile with timeline**: Use DevTools to identify bottlenecks

---

## Debugging Techniques

### 1. Print Widget Tree

```dart
import 'package:flutter/material.dart';

void printWidgetTree(BuildContext context) {
  context.visitChildElements((element) {
    print('${element.widget.runtimeType}');
    element.visitChildElements((child) {
      print('  ${child.widget.runtimeType}');
    });
  });
}
```

### 2. Use Semantics Inspector

```dart
testWidgets('Inspect semantics', (tester) async {
  app.main();
  await IntegrationTestUtils.waitForAppToSettle(tester);

  // Print accessibility tree
  final semantics = tester.getSemantics(find.byType(MaterialApp));
  print('Semantic node: $semantics');
});
```

### 3. Capture Debug Info on Failure

```dart
testWidgets('Test with debug capture', (tester) async {
  addTearDown(
    () async {
      if (testWidgetsTester.testCaseSource.errorCount > 0) {
        print('Captures debug info on test failure');
        // Could save logs, screenshots, etc.
      }
    },
  );

  // Test code here
});
```

---

## Best Practices to Avoid Issues

1. **Always settle after interactions**
   ```dart
   await IntegrationTestUtils.tapAndSettle(tester, button);
   ```

2. **Use keys for unique widgets**
   ```dart
   ElevatedButton(key: UniqueKey(), ...)
   ```

3. **Handle optional widgets**
   ```dart
   if (find.byType(Widget).evaluate().isNotEmpty) {
     // Widget exists
   }
   ```

4. **Set timeouts on network requests**
   ```dart
   await api.fetchData().timeout(Duration(seconds: 10));
   ```

5. **Clean up resources in tearDown**
   ```dart
   tearDown(() {
     // Clean up test data
   });
   ```

---

## Getting Help

When issues persist:

1. **Check Flutter documentation**: https://flutter.dev/docs/testing
2. **Review test output**: Look for hints in error messages
3. **Enable verbose logging**: `flutter test -v`
4. **Check package versions**: `flutter pub outdated`
5. **File issue with Flutter team**: https://github.com/flutter/flutter/issues

---

## Related Documentation

- [Integration Testing - Setup Guide](BROWSERSTACK_COMPLETE_SETUP.md)
- [Test Utils - Complete Guide](INTEGRATION_TEST_UTILS_GUIDE.md)
- [Flutter Testing Overview](https://flutter.dev/docs/testing)
- [BrowserStack App Automate](https://www.browserstack.com/app-automate/flutter)
