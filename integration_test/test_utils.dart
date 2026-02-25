import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mynotes/main.dart' as app;

/// Common integration test utilities and helpers
class IntegrationTestUtils {
  /// Wait for the app to settle after a navigation
  static Future<void> waitForAppToSettle(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  /// Wait for a specific duration
  static Future<void> wait(WidgetTester tester, Duration duration) async {
    await tester.pump(duration);
  }

  /// Verify that a widget exists
  static void verifyWidgetExists(Finder finder, {String? description}) {
    expect(finder, findsWidgets, reason: description);
  }

  /// Verify that a widget doesn't exist
  static void verifyWidgetAbsent(Finder finder, {String? description}) {
    expect(finder, findsNothing, reason: description);
  }

  /// Verify that a widget exists exactly once
  static void verifyWidgetExistsOnce(Finder finder, {String? description}) {
    expect(finder, findsOneWidget, reason: description);
  }

  /// Verify that a widget exists n times
  static void verifyWidgetExistsNTimes(
    Finder finder,
    int count, {
    String? description,
  }) {
    expect(finder, findsNWidgets(count), reason: description);
  }

  /// Tap a widget and wait for settlement
  static Future<void> tapAndSettle(
    WidgetTester tester,
    Finder finder, {
    Duration duration = const Duration(seconds: 2),
  }) async {
    await tester.tap(finder);
    await tester.pumpAndSettle(duration);
  }

  /// Enter text in a text field
  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text, {
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle(duration);
  }

  /// Clear text in a text field
  static Future<void> clearText(
    WidgetTester tester,
    Finder finder, {
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    await tester.tap(finder);
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.enterText(finder, '');
    await tester.pumpAndSettle(duration);
  }

  /// Scroll within a scrollable widget
  static Future<void> scroll(
    WidgetTester tester,
    Finder finder, {
    required Offset offset,
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    await tester.drag(finder, offset);
    await tester.pumpAndSettle(duration);
  }

  /// Scroll to the top of a scrollable
  static Future<void> scrollToTop(
    WidgetTester tester,
    Finder scrollable,
  ) async {
    while (true) {
      final result = await tester.pumpAndSettle();
      if (result == 0) break;
      await tester.drag(scrollable, const Offset(0, 300));
      await tester.pump();
    }
  }

  /// Verify text content
  static void verifyText(String text) {
    expect(find.text(text), findsWidgets);
  }

  /// Verify text doesn't exist
  static void verifyTextAbsent(String text) {
    expect(find.text(text), findsNothing);
  }

  /// Take a screenshot for debugging (automated by BrowserStack)
  static void captureScreenshot() {
    // Screenshots are automatically captured by BrowserStack during test execution
    // No manual action needed - device logs will include screenshots
  }

  /// Verify widget with specific key exists
  static void verifyWidgetByKey(dynamic key) {
    expect(find.byKey(key), findsWidgets);
  }

  /// Tap widget by key
  static Future<void> tapByKey(
    WidgetTester tester,
    dynamic key, {
    Duration duration = const Duration(seconds: 2),
  }) async {
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle(duration);
  }

  /// Double tap a widget
  static Future<void> doubleTap(
    WidgetTester tester,
    Finder finder, {
    Duration duration = const Duration(seconds: 2),
  }) async {
    await tester.tap(finder);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(finder);
    await tester.pumpAndSettle(duration);
  }

  /// Long press a widget
  static Future<void> longPress(
    WidgetTester tester,
    Finder finder, {
    Duration duration = const Duration(seconds: 2),
  }) async {
    await tester.longPress(finder);
    await tester.pumpAndSettle(duration);
  }

  /// Verify single widget exists with type
  static void verifyExactlyOne(Type widgetType) {
    expect(find.byType(widgetType as Type), findsOneWidget);
  }
}
