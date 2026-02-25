# Integration Test Utils - Complete Guide

## Overview

The `test_utils.dart` file provides a comprehensive set of helper methods for writing integration tests in Flutter. These utilities abstract away common test patterns, making test code more readable and maintainable while following modern Flutter best practices.

## Architecture

### Design Principles

1. **Modern Flutter APIs**: All utilities use current, non-deprecated Flutter test APIs
2. **Reusability**: Common patterns are extracted into helper methods
3. **Readability**: Method names clearly describe what they do
4. **Type Safety**: Strong typing throughout
5. **Error Handling**: Proper timeouts and error messages

### Method Categories

```
IntegrationTestUtils
├── Core Utilities (wait, settle, pump)
├── Text Input Operations (enter, clear)
├── Widget Verification (exists, absent, count)
├── Text Verification (verify, absent)
├── Gesture Operations (tap, double-tap, long-press)
├── Scrolling Operations (scroll, scroll-to-top)
├── Key-based Operations (find-by-key, tap-by-key)
└── Screenshots (capture)
```

## Core Utilities

### waitForAppToSettle(WidgetTester tester)

**Purpose**: Waits for all animations and pending frames to settle

**Usage**:
```dart
app.main();
await IntegrationTestUtils.waitForAppToSettle(tester);
// App is now in a stable state
```

**When to use**:
- After launching the app
- After navigation transitions
- After state changes that trigger animations
- Before verifying UI elements

**Timeout**: 30 seconds (configurable if needed)

---

### wait(WidgetTester tester, Duration duration)

**Purpose**: Waits for an explicit duration without checking for settlement

**Usage**:
```dart
// Wait for something specific to happen (e.g., timer, animation)
await IntegrationTestUtils.wait(tester, Duration(seconds: 2));
```

**When to use**:
- When you need to wait for a specific duration
- When you know exactly how long to wait
- For testing time-dependent features

---

### tapAndSettle(WidgetTester tester, Finder finder)

**Purpose**: Taps a widget and waits for animations to settle

**Usage**:
```dart
final button = find.byType(ElevatedButton);
await IntegrationTestUtils.tapAndSettle(tester, button);
// Button is tapped and all animations have settled
```

**When to use**:
- Tapping buttons that trigger animations
- Navigating to new screens
- Opening dialogs or modals

---

## Text Input Operations

### enterText(WidgetTester tester, Finder finder, String text)

**Purpose**: Finds a text field, clears it, enters new text, and waits for settlement

**Usage**:
```dart
final textField = find.byType(TextField);
await IntegrationTestUtils.enterText(tester, textField, 'Hello World');
```

**Features**:
- Automatically clears existing text
- Clears focus after entering text
- Waits for animations

**When to use**:
- Typing into text fields
- Filling forms
- Testing input validation

---

### clearText(WidgetTester tester, Finder finder)

**Purpose**: Clears all text from a text field

**Usage**:
```dart
final textField = find.byType(TextField);
await IntegrationTestUtils.clearText(tester, textField);
```

**When to use**:
- Resetting form fields
- Preparing for new input
- Testing empty state

---

## Widget Verification

### verifyWidgetExists(Finder finder)

**Purpose**: Verifies that at least one widget matching the finder exists

**Usage**:
```dart
IntegrationTestUtils.verifyWidgetExists(find.byType(MaterialApp));
// Throws if no MaterialApp found
```

**When to use**:
- Checking if UI elements are present
- Basic existence checks
- Non-critical verifications

---

### verifyWidgetExistsOnce(Finder finder)

**Purpose**: Verifies that exactly one widget matches the finder

**Usage**:
```dart
IntegrationTestUtils.verifyWidgetExistsOnce(find.byType(Scaffold));
// Throws if not exactly one Scaffold
```

**When to use**:
- Verifying unique UI elements
- Ensuring no duplicate widgets
- Critical UI structure checks

---

### verifyWidgetExistsNTimes(Finder finder, int count)

**Purpose**: Verifies that exactly N widgets match the finder

**Usage**:
```dart
IntegrationTestUtils.verifyWidgetExistsNTimes(
  find.byType(Card),
  5, // Expecting 5 cards
);
```

**When to use**:
- Verifying list item counts
- Checking grid layouts
- Validating dynamic content

---

### verifyWidgetAbsent(Finder finder)

**Purpose**: Verifies that no widgets match the finder

**Usage**:
```dart
IntegrationTestUtils.verifyWidgetAbsent(find.byType(LoadingSpinner));
// Throws if any LoadingSpinner found
```

**When to use**:
- Checking that error states are hidden
- Verifying loading indicators are gone
- Ensuring optional UI is not shown

---

### verifyWidgetByKey(String key)

**Purpose**: Verifies a widget exists by its string key

**Usage**:
```dart
IntegrationTestUtils.verifyWidgetByKey('submit_button');
// Widget with key 'submit_button' exists
```

**When to use**:
- Testing widgets identified by semantic keys
- Accessing specific named widgets
- KeyedWidget verification

---

### verifyExactlyOne(Type type)

**Purpose**: Shorthand to verify exactly one widget of a type exists

**Usage**:
```dart
IntegrationTestUtils.verifyExactlyOne(AppBar);
// Exactly one AppBar exists
```

**When to use**:
- Quick verification of unique UI elements
- More readable than alternative syntax

---

## Text Verification

### verifyText(String text)

**Purpose**: Verifies that text appears somewhere in the widget tree

**Usage**:
```dart
IntegrationTestUtils.verifyText('Welcome Back');
// Text 'Welcome Back' exists in the app
```

**When to use**:
- Checking message displays
- Verifying success/error messages
- Validating user-facing strings

---

### verifyTextAbsent(String text)

**Purpose**: Verifies that text does NOT appear in the widget tree

**Usage**:
```dart
IntegrationTestUtils.verifyTextAbsent('Loading...');
// 'Loading...' text is not visible
```

**When to use**:
- Checking loading indicators are hidden
- Verifying error messages are cleared
- Ensuring old content is replaced

---

## Gesture Operations

### doubleTap(WidgetTester tester, Finder finder)

**Purpose**: Double-taps a widget

**Usage**:
```dart
final widget = find.byType(GestureDetector);
await IntegrationTestUtils.doubleTap(tester, widget);
```

**When to use**:
- Testing double-tap handlers
- Zooming in/out
- Quick action triggers

---

### longPress(WidgetTester tester, Finder finder)

**Purpose**: Long-presses a widget (500ms)

**Usage**:
```dart
final item = find.byType(ListTile);
await IntegrationTestUtils.longPress(tester, item);
```

**When to use**:
- Context menu triggers
- Selection operations
- Long-press actions

---

### tapByKey(WidgetTester tester, String key)

**Purpose**: Taps a widget identified by its string key

**Usage**:
```dart
await IntegrationTestUtils.tapByKey(tester, 'delete_button');
```

**When to use**:
- Tapping specifically keyed widgets
- When Finder is not convenient
- Semantic widget identification

---

## Scrolling Operations

### scroll(WidgetTester tester, Finder scrollable, Offset offset, Duration duration)

**Purpose**: Scrolls a scrollable widget by a given offset

**Usage**:
```dart
final listView = find.byType(ListView);
await IntegrationTestUtils.scroll(
  tester,
  listView,
  Offset(0, -300), // Scroll up by 300px
  Duration(milliseconds: 500),
);
```

**Parameters**:
- `scrollable`: The scrollable widget to scroll
- `offset`: The movement vector (negative = up for vertical)
- `duration`: How long the scroll animation takes

**When to use**:
- Testing scroll-to-load
- Accessing items below fold
- Testing scroll behavior

---

### scrollToTop(WidgetTester tester, Finder scrollable)

**Purpose**: Scrolls a scrollable widget to the top

**Usage**:
```dart
final listView = find.byType(ListView);
await IntegrationTestUtils.scrollToTop(tester, listView);
```

**When to use**:
- Resetting scroll position
- Testing pull-to-refresh
- Returning to start of list

---

## Screenshot Management

### captureScreenshot()

**Purpose**: Captures a screenshot (BrowserStack handles automatically)

**Usage**:
```dart
// During a test
IntegrationTestUtils.captureScreenshot();
```

**Note**: BrowserStack automatically captures screenshots at key points in your tests. This method is primarily for documentation purposes.

---

## Complete Test Example

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mynotes/main.dart' as app;
import 'test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete user flow test', (WidgetTester tester) async {
    // Launch app and wait for stability
    app.main();
    await IntegrationTestUtils.waitForAppToSettle(tester);

    // Verify app is ready
    IntegrationTestUtils.verifyWidgetExists(find.byType(MaterialApp));

    // Find and fill a form
    final nameField = find.byType(TextField).first;
    await IntegrationTestUtils.enterText(tester, nameField, 'John Doe');

    // Verify input
    IntegrationTestUtils.verifyText('John Doe');

    // Find and tap submit button
    final submitButton = find.byKey(ValueKey('submit'));
    await IntegrationTestUtils.tapAndSettle(tester, submitButton);

    // Wait for processing
    await IntegrationTestUtils.wait(tester, Duration(seconds: 1));

    // Verify success message
    IntegrationTestUtils.verifyText('Submitted successfully');

    // Scroll to see more content if needed
    final scrollView = find.byType(SingleChildScrollView);
    if (scrollView.evaluate().isNotEmpty) {
      await IntegrationTestUtils.scrollToTop(tester, scrollView);
    }

    // Verify final state
    IntegrationTestUtils.verifyWidgetExists(find.byType(SnackBar));
  });
}
```

---

## Best Practices

### 1. Use Descriptive Test Names

```dart
// ✅ Good
testWidgets('User can create a note with title and description', ...)

// ❌ Bad
testWidgets('Test note creation', ...)
```

### 2. Wait for Settlement Always

```dart
// ✅ Good
await IntegrationTestUtils.waitForAppToSettle(tester);

// ❌ Bad
await tester.pump();  // May not wait long enough
```

### 3. Use Keys for Specific Widgets

```dart
// Create widgets with keys
ElevatedButton(
  key: const ValueKey('submit_button'),
  onPressed: () {},
  child: Text('Submit'),
)

// Then test with key
await IntegrationTestUtils.tapByKey(tester, 'submit_button');
```

### 4. Group Related Tests

```dart
group('Authentication', () {
  testWidgets('User can log in', ...);
  testWidgets('User can log out', ...);
  testWidgets('User sees error with invalid credentials', ...);
});
```

### 5. Test User Actions, Not Implementation

```dart
// ✅ Good - Tests what user sees
IntegrationTestUtils.verifyText('Welcome Back, John');

// ❌ Bad - Tests internal state
expect(viewModel.currentUser.name, 'John');
```

### 6. Handle Optional Elements

```dart
// Check if element exists before acting on it
final optionalButton = find.byType(FloatingActionButton);
if (optionalButton.evaluate().isNotEmpty) {
  await IntegrationTestUtils.tapAndSettle(tester, optionalButton);
}
```

### 7. Use Appropriate Timeouts

```dart
// Long operations may need more time
await IntegrationTestUtils.wait(tester, Duration(seconds: 5));

// API calls might take time
await IntegrationTestUtils.waitForAppToSettle(tester);
```

---

## Debugging Tips

### 1. Print Widget Tree

```dart
debugPrintBeginFrame = true;
debugPrintEndFrame = true;

// Dump widget tree
tester.printToConsole();
```

### 2. Increase Timeout for Debugging

Modify `waitForAppToSettle` timeout temporarily:

```dart
await tester.pumpAndSettle(
  const Duration(seconds: 60),  // Extended timeout
);
```

### 3. Check Available Finders

```dart
// List all widgets of a type
print(find.byType(Text).evaluate().length);

// Check specific text
print(find.text('Debug').evaluate().isNotEmpty);
```

### 4. Use Screenshots

```dart
// BrowserStack captures automatically, but you can document key points
IntegrationTestUtils.captureScreenshot();
```

---

## Migration from Old APIs

### If you see deprecation warnings:

**Old Code**:
```dart
tester.binding.window.physicalSizeTestValue = Size(1080, 1920);
addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
```

**New Code**:
```dart
// Let the test framework handle sizing
// Use IntegrationTestUtils methods instead
```

**Old Code**:
```dart
await tester.takeScreenshot('screenshot_name');
```

**New Code**:
```dart
// Use BrowserStack's automatic screenshot feature
IntegrationTestUtils.captureScreenshot();
```

---

## Troubleshooting

### "Finder matched multiple widgets"

```dart
// Wrong - matches multiple
find.byType(Text)

// Correct - specific widget
find.byType(Text).first
find.byWidget(mySpecificWidget)
find.byKey(ValueKey('unique_id'))
```

### "Timeout waiting for settlement"

```dart
// Your app may have infinite animations
// Check for:
// 1. Infinite animation controllers
// 2. Continuous physics-based animations
// 3. Auto-scrolling lists

// Solution: Fix infinite animations, not the test
```

### "Text not found even though I see it"

```dart
// Text may be in a semantics node, not rendered as Text widget
// Use BySemanticsLabel instead:
find.bySemanticsLabel('My Label')
```

---

## Performance Considerations

### Test Execution Time

- **Fast tests**: < 1 second (no animations, instant interactions)
- **Medium tests**: 1-5 seconds (with animations, settle waits)
- **Slow tests**: 5-30 seconds (multiple interactions, long waits)

### Optimization Tips

1. **Disable animations in tests**:
```dart
// In test setup
tester.binding.window.onPlatformMessage = (String name, ...) async {
  if (name == 'flutter/platform') {
    // Handle accordingly
  }
};
```

2. **Batch operations**:
```dart
// ✅ Good - settle once after multiple pumps
await tester.pump();
await tester.pump();
await tester.pump();
await IntegrationTestUtils.waitForAppToSettle(tester);

// ❌ Bad - settle after each pump
await tester.pumpAndSettle();
await tester.pumpAndSettle();
```

3. **Skip unnecessary waits**:
```dart
// ✅ Good - only wait when needed
if (loadingIndicator.evaluate().isNotEmpty) {
  await IntegrationTestUtils.waitForAppToSettle(tester);
}

// ❌ Bad - always wait
await IntegrationTestUtils.waitForAppToSettle(tester);
```

---

## Summary

The `IntegrationTestUtils` class provides all the utilities you need to write clear, maintainable integration tests. The methods follow standard Flutter test patterns and avoid deprecated APIs, ensuring compatibility with current and future Flutter versions.

For questions or issues, refer to:
- [Flutter Integration Testing Guide](https://flutter.dev/docs/testing/integration-tests)
- [Flutter Test APIs](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html)
- [BrowserStack App Automate Documentation](https://www.browserstack.com/app-automate/flutter)
