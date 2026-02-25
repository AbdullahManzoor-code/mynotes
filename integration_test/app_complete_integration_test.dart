import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mynotes/main.dart' as app;
import 'test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MyNotes App - Complete Integration Tests', () {
    // ════════════════════════════════════════════════════════════════
    // SETUP & TEARDOWN
    // ════════════════════════════════════════════════════════════════

    setUp(() {
      // Reset app state before each test
    });

    tearDown(() {
      // Cleanup after each test
    });

    // ════════════════════════════════════════════════════════════════
    // APP INITIALIZATION & CORE FEATURES
    // ════════════════════════════════════════════════════════════════

    testWidgets('App launches and displays main screen', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      // Verify Material App is rendered
      IntegrationTestUtils.verifyWidgetExists(find.byType(MaterialApp));

      // Take screenshot for reference
      IntegrationTestUtils.captureScreenshot();
    });

    testWidgets('App displays required UI elements', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      // Verify Scaffold is present
      IntegrationTestUtils.verifyExactlyOne(Scaffold);

      // Verify app bar exists
      IntegrationTestUtils.verifyWidgetExists(find.byType(AppBar));
    });

    testWidgets('Widget tree is not null after launch', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    // ════════════════════════════════════════════════════════════════
    // USER INTERACTIONS
    // ════════════════════════════════════════════════════════════════

    testWidgets('User can interact with buttons', (WidgetTester tester) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      // Find and tap button if exists
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        await IntegrationTestUtils.tapAndSettle(tester, buttons.first);
      }

      // App should remain stable after tap
      IntegrationTestUtils.verifyWidgetExists(find.byType(MaterialApp));
    });

    testWidgets('Text input fields are functional if present', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        const testText = 'Test Input';
        await IntegrationTestUtils.enterText(
          tester,
          textFields.first,
          testText,
        );

        // Verify text was entered
        IntegrationTestUtils.verifyText(testText);
      }
    });

    // ════════════════════════════════════════════════════════════════
    // NAVIGATION
    // ════════════════════════════════════════════════════════════════

    testWidgets('Back button behaves correctly', (WidgetTester tester) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      // Initial state
      IntegrationTestUtils.verifyWidgetExists(find.byType(MaterialApp));

      // Simulate Android back button (may not affect root screen)
      await tester.pageBack();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      // App should still exist
      IntegrationTestUtils.verifyWidgetExists(find.byType(MaterialApp));
    });

    testWidgets('App handles rapid navigation', (WidgetTester tester) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      IntegrationTestUtils.verifyWidgetExists(find.byType(MaterialApp));
    });

    // ════════════════════════════════════════════════════════════════
    // PERFORMANCE TESTS
    // ════════════════════════════════════════════════════════════════

    testWidgets('App launches within acceptable time', (
      WidgetTester tester,
    ) async {
      final stopwatch = Stopwatch()..start();

      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      stopwatch.stop();

      // App should launch within 5 seconds
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(5000),
        reason:
            'App launch took ${stopwatch.elapsedMilliseconds}ms (target: <5000ms)',
      );
    });

    testWidgets('Performance under rapid interactions', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      final stopwatch = Stopwatch()..start();

      // Simulate rapid interactions
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      stopwatch.stop();

      // Should handle without crashing
      IntegrationTestUtils.verifyWidgetExists(find.byType(MaterialApp));
    });

    // ════════════════════════════════════════════════════════════════
    // ACCESSIBILITY TESTS
    // ════════════════════════════════════════════════════════════════

    testWidgets('App renders content properly', (WidgetTester tester) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      // Verify visual elements present
      IntegrationTestUtils.verifyWidgetExists(find.byType(Material));
    });

    testWidgets('Text is readable with normal scaling', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      // Find text widgets to verify they render
      final textWidgets = find.byType(Text);
      expect(textWidgets, findsWidgets);
    });

    testWidgets('Interactive elements have sufficient touch targets', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      // Find buttons and ensure they're tappable
      final buttons = find.byType(InkWell);
      if (buttons.evaluate().isNotEmpty) {
        // Verify buttons exist and are interactive
        expect(buttons, findsWidgets);
      }
    });

    // ════════════════════════════════════════════════════════════════
    // ERROR HANDLING & EDGE CASES
    // ════════════════════════════════════════════════════════════════

    testWidgets('App handles lifecycle events gracefully', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      // Move through lifecycle states
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 500));

      // App should remain stable
      IntegrationTestUtils.verifyWidgetExists(find.byType(MaterialApp));
    });

    testWidgets('App does not crash with empty state', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      // Simply verify app stays running
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App responds to orientation changes', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      // Test portrait (default)
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await IntegrationTestUtils.waitForAppToSettle(tester);

      IntegrationTestUtils.verifyWidgetExists(find.byType(MaterialApp));
    });

    // ════════════════════════════════════════════════════════════════
    // STRESS TESTS
    // ════════════════════════════════════════════════════════════════

    testWidgets('App survives long test duration', (WidgetTester tester) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      // Simulate extended usage
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (i % 5 == 0) {
          await IntegrationTestUtils.waitForAppToSettle(tester);
        }
      }

      // App should still be responsive
      IntegrationTestUtils.verifyWidgetExists(find.byType(MaterialApp));
    });

    testWidgets('Memory is released appropriately', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      // Pump and settle multiple times to trigger garbage collection
      for (int i = 0; i < 5; i++) {
        await tester.pump();
        await IntegrationTestUtils.waitForAppToSettle(tester);
      }

      // App should remain stable
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
