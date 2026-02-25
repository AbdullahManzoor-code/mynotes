# Integration Test Utils - Quick Reference Card

## Method Cheat Sheet

### SETUP
```dart
import 'test_utils.dart';
import 'package:mynotes/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Test name', (tester) async {
    app.main();
    await IntegrationTestUtils.waitForAppToSettle(tester);
    // Test here
  });
}
```

---

## Core Methods

### Waiting & Settlement
| Method | Purpose | Usage |
|--------|---------|-------|
| `waitForAppToSettle` | Wait for all animations | `await IntegrationTestUtils.waitForAppToSettle(tester);` |
| `wait` | Wait explicit duration | `await IntegrationTestUtils.wait(tester, Duration(seconds: 2));` |
| `tapAndSettle` | Tap and wait | `await IntegrationTestUtils.tapAndSettle(tester, finder);` |

### Text Input
| Method | Purpose | Usage |
|--------|---------|-------|
| `enterText` | Enter text in field | `await IntegrationTestUtils.enterText(tester, finder, 'text');` |
| `clearText` | Clear text field | `await IntegrationTestUtils.clearText(tester, finder);` |

### Widget Verification
| Method | Purpose | Usage |
|--------|---------|-------|
| `verifyWidgetExists` | Any widgets exist | `IntegrationTestUtils.verifyWidgetExists(find.byType(Button));` |
| `verifyWidgetExistsOnce` | Exactly 1 widget | `IntegrationTestUtils.verifyWidgetExistsOnce(find.byType(AppBar));` |
| `verifyWidgetExistsNTimes` | N widgets | `IntegrationTestUtils.verifyWidgetExistsNTimes(find.byType(Card), 5);` |
| `verifyWidgetAbsent` | No widgets | `IntegrationTestUtils.verifyWidgetAbsent(find.byType(Error));` |
| `verifyWidgetByKey` | Find by key | `IntegrationTestUtils.verifyWidgetByKey('button_key');` |
| `verifyExactlyOne` | Exactly 1 of type | `IntegrationTestUtils.verifyExactlyOne(Scaffold);` |

### Text Verification
| Method | Purpose | Usage |
|--------|---------|-------|
| `verifyText` | Text exists | `IntegrationTestUtils.verifyText('Welcome');` |
| `verifyTextAbsent` | Text missing | `IntegrationTestUtils.verifyTextAbsent('Loading...');` |

### Gestures
| Method | Purpose | Usage |
|--------|---------|-------|
| `doubleTap` | Double-tap | `await IntegrationTestUtils.doubleTap(tester, finder);` |
| `longPress` | Long-press | `await IntegrationTestUtils.longPress(tester, finder);` |
| `tapByKey` | Tap by key | `await IntegrationTestUtils.tapByKey(tester, 'key');` |

### Scrolling
| Method | Purpose | Usage |
|--------|---------|-------|
| `scroll` | Scroll widget | `await IntegrationTestUtils.scroll(tester, finder, Offset(0, -300), duration);` |
| `scrollToTop` | Scroll to top | `await IntegrationTestUtils.scrollToTop(tester, finder);` |

### Other
| Method | Purpose | Usage |
|--------|---------|-------|
| `captureScreenshot` | Screenshot | `IntegrationTestUtils.captureScreenshot();` |

---

## Common Test Patterns

### Pattern 1: Fill Form & Submit
```dart
testWidgets('User fills and submits form', (tester) async {
  app.main();
  await IntegrationTestUtils.waitForAppToSettle(tester);

  // Fill field 1
  await IntegrationTestUtils.enterText(
    tester,
    find.byType(TextField).at(0),
    'John Doe',
  );

  // Fill field 2
  await IntegrationTestUtils.enterText(
    tester,
    find.byType(TextField).at(1),
    'john@example.com',
  );

  // Submit
  await IntegrationTestUtils.tapAndSettle(
    tester,
    find.byType(ElevatedButton),
  );

  // Verify success
  IntegrationTestUtils.verifyText('Success');
});
```

### Pattern 2: Navigation Flow
```dart
testWidgets('User navigates through screens', (tester) async {
  app.main();
  await IntegrationTestUtils.waitForAppToSettle(tester);

  // Navigate to detail screen
  await IntegrationTestUtils.tapAndSettle(
    tester,
    find.byKey(ValueKey('item_1')),
  );

  // Verify detail screen
  IntegrationTestUtils.verifyText('Detail Screen');

  // Go back
  await tester.pageBack();
  await IntegrationTestUtils.waitForAppToSettle(tester);

  // Verify list screen
  IntegrationTestUtils.verifyText('List Screen');
});
```

### Pattern 3: List Scrolling & Interaction
```dart
testWidgets('User scrolls and interacts with list', (tester) async {
  app.main();
  await IntegrationTestUtils.waitForAppToSettle(tester);

  // Scroll list
  await IntegrationTestUtils.scroll(
    tester,
    find.byType(ListView),
    Offset(0, -500), // Scroll up 500px
    Duration(milliseconds: 500),
  );

  // Tap item in scrolled position
  await IntegrationTestUtils.tapAndSettle(
    tester,
    find.text('Item 10'),
  );

  // Verify interaction result
  IntegrationTestUtils.verifyText('Item 10 selected');
});
```

### Pattern 4: Dialog/Modal Testing
```dart
testWidgets('User interacts with dialog', (tester) async {
  app.main();
  await IntegrationTestUtils.waitForAppToSettle(tester);

  // Open dialog
  await IntegrationTestUtils.tapAndSettle(
    tester,
    find.byType(ElevatedButton),
  );

  // Verify dialog appeared
  IntegrationTestUtils.verifyWidgetExists(find.byType(AlertDialog));

  // Fill dialog field
  await IntegrationTestUtils.enterText(
    tester,
    find.byType(TextField),
    'Input',
  );

  // Confirm dialog
  await IntegrationTestUtils.tapAndSettle(
    tester,
    find.text('OK'),
  );

  // Verify dialog closed
  IntegrationTestUtils.verifyWidgetAbsent(find.byType(AlertDialog));
});
```

### Pattern 5: Long-Press Menu
```dart
testWidgets('User opens context menu', (tester) async {
  app.main();
  await IntegrationTestUtils.waitForAppToSettle(tester);

  // Long-press item
  await IntegrationTestUtils.longPress(
    tester,
    find.byType(ListTile).first,
  );

  // Verify menu appeared
  IntegrationTestUtils.verifyText('Edit');
  IntegrationTestUtils.verifyText('Delete');

  // Tap menu option
  await IntegrationTestUtils.tapAndSettle(
    tester,
    find.text('Delete'),
  );

  // Verify action result
  IntegrationTestUtils.verifyText('Item deleted');
});
```

### Pattern 6: Performance Monitoring
```dart
testWidgets('App launch is fast', (tester) async {
  final stopwatch = Stopwatch()..start();

  app.main();
  await IntegrationTestUtils.waitForAppToSettle(tester);

  stopwatch.stop();

  // Assert launch time
  expect(
    stopwatch.elapsedMilliseconds,
    lessThan(5000),
    reason: 'Launch took ${stopwatch.elapsedMilliseconds}ms',
  );
});
```

### Pattern 7: Conditional Widget Testing
```dart
testWidgets('Tests optional widgets correctly', (tester) async {
  app.main();
  await IntegrationTestUtils.waitForAppToSettle(tester);

  // Check if widget exists
  final fab = find.byType(FloatingActionButton);
  if (fab.evaluate().isNotEmpty) {
    // Tap it
    await IntegrationTestUtils.tapAndSettle(tester, fab);
  }

  // Always verify something
  IntegrationTestUtils.verifyWidgetExists(find.byType(MaterialApp));
});
```

### Pattern 8: Text Clearing & Re-entry
```dart
testWidgets('User can edit text field', (tester) async {
  app.main();
  await IntegrationTestUtils.waitForAppToSettle(tester);

  final field = find.byType(TextField);

  // Enter initial text
  await IntegrationTestUtils.enterText(tester, field, 'Original');
  IntegrationTestUtils.verifyText('Original');

  // Clear and re-enter
  await IntegrationTestUtils.clearText(tester, field);
  IntegrationTestUtils.verifyTextAbsent('Original');

  await IntegrationTestUtils.enterText(tester, field, 'Updated');
  IntegrationTestUtils.verifyText('Updated');
});
```

---

## Finder Recipes

### Find by Widget Type
```dart
find.byType(ElevatedButton)
find.byType(TextField).first
find.byType(ListTile).at(2)
```

### Find by Text
```dart
find.text('Exact Text Match')
find.byTooltipMessage('Help tooltip')
```

### Find by Key
```dart
find.byKey(ValueKey('unique_id'))
find.bySemanticsLabel('Button Label')
```

### Find by Custom Predicate
```dart
find.byWidgetPredicate((widget) {
  return widget is Text && widget.data?.contains('partial') == true;
})
```

### Combine Finders
```dart
find.descendant(
  of: find.byType(Column),
  matching: find.byType(Text),
)
```

---

## Key Shortcuts

### For Widget by Key (Most Efficient)
```dart
// In widget definition
ElevatedButton(
  key: ValueKey('submit_button'),
  onPressed: () {},
  child: Text('Submit'),
)

// In test
await IntegrationTestUtils.tapByKey(tester, 'submit_button');
```

### For Text Widgets
```dart
// Verify text exists
IntegrationTestUtils.verifyText('Welcome');

// Tap text button
await IntegrationTestUtils.tapAndSettle(
  tester,
  find.text('Submit'),
);
```

### For Material Widgets
```dart
// Find specific Material widgets
find.byType(FloatingActionButton)
find.byType(BottomNavigationBar)
find.byType(Drawer)
find.byType(AppBar)
```

---

## Timing Guide

| Operation | Typical Duration |
|-----------|------------------|
| App launch | 1-3 seconds |
| Screen transition | 300-500 ms |
| Animation settle | 500 ms - 2 seconds |
| Network API call | 2-5 seconds |
| Snapshot wait | 30 seconds (max) |

### When to use each wait method

```dart
// Quick interactions (taps, text entry)
await IntegrationTestUtils.tapAndSettle(tester, button);

// After navigation
await IntegrationTestUtils.waitForAppToSettle(tester);

// Specific waits
await IntegrationTestUtils.wait(tester, Duration(seconds: 2));

// For snapshots (no explicit wait needed)
await IntegrationTestUtils.waitForAppToSettle(tester);
```

---

## Error Messages & Fixes

| Error | Likely Cause | Fix |
|-------|-------------|-----|
| "Finder matched 0 widgets" | Widget doesn't exist | Check widget is built, verify finder |
| "Finder matched 2 widgets" | Multiple matches | Add `.first`, `.at(0)`, or use key |
| "Text '...' not found" | Exact text doesn't match | Use `find.text('exact')` or debug |
| "Timeout waiting for settlement" | Infinite animations | Check AnimationController, fix infinite loops |
| "Missing selector" | Deprecated TestWindow API | Use modern methods from IntegrationTestUtils |
| "Illegal assignment" | Trying to reassign read-only property | Don't modify window/binding properties |

---

## Testing Checklist

- [ ] App launches successfully
- [ ] UI elements render correctly
- [ ] User can interact with buttons
- [ ] Text input works
- [ ] Navigation between screens works
- [ ] Lists/grids scroll properly
- [ ] Forms validate and submit
- [ ] Error messages display
- [ ] Loading states show/hide
- [ ] Performance is acceptable (<5s launch)
- [ ] Accessibility elements present
- [ ] No deprecation warnings
- [ ] No infinite loops or hangs
- [ ] Tests pass on Android and iOS

---

## Setup (Copy-Paste Template)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mynotes/main.dart' as app;
import 'test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MyNotes Integration Tests', () {
    testWidgets('Test name here', (WidgetTester tester) async {
      // Launch app
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      // Test code here

      // Verify result
      IntegrationTestUtils.verifyWidgetExists(find.byType(MaterialApp));
    });
  });
}
```

---

## Running Tests

### Local (Android/iOS Emulator)
```bash
flutter test integration_test/app_test.dart
```

### On Device
```bash
flutter test integration_test/app_test.dart --device-id <device_id>
```

### With Verbose Output
```bash
flutter test integration_test/app_test.dart -v
```

### BrowserStack (Android)
```bash
./scripts/browserstack_upload.sh
```

### BrowserStack (iOS)
```bash
./scripts/browserstack_upload_ios.sh
```

---

## Pro Tips

1. **Always settle after interactions**: Use `tapAndSettle` for reliability
2. **Use Keys for critical widgets**: Avoids fragile text/type matching
3. **Test user actions, not implementation**: Click buttons, don't call functions
4. **Keep tests focused**: One scenario per test
5. **Use descriptive names**: Future you will thank current you
6. **Group related tests**: Organize with `group()` blocks
7. **Handle optional widgets**: Check existence before asserting
8. **Set reasonable timeouts**: Don't make tests wait longer than needed
9. **Capture screenshots at key points**: BrowserStack does this automatically
10. **Clean up resources**: Use `tearDown()` to reset state

---

## Quick Links

- [Full Utils Guide](INTEGRATION_TEST_UTILS_GUIDE.md)
- [Setup instructions](BROWSERSTACK_COMPLETE_SETUP.md)
- [Troubleshooting](INTEGRATION_TESTING_TROUBLESHOOTING.md)
- [Flutter Testing Docs](https://flutter.dev/docs/testing)
- [BrowserStack App Automate](https://www.browserstack.com/app-automate)
