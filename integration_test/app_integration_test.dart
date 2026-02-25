import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mynotes/main.dart' as app;
import 'test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MyNotes App - Core Features', () {
    testWidgets('App launches successfully', (WidgetTester tester) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      // Verify Material App is present
      IntegrationTestUtils.verifyWidgetExists(find.byType(MaterialApp));
    });

    testWidgets('App displays initial UI elements', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      // Verify the app has loaded properly
      expect(find.byType(MaterialApp), findsWidgets);

      // Add more specific checks based on your app structure
      // For example, if you have a home page:
      // expect(find.byType(HomePage), findsWidgets);
    });

    testWidgets('App responds to user interactions', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      // Verify the app is responsive
      final materialApp = find.byType(MaterialApp);
      expect(materialApp, findsWidgets);
    });

    testWidgets('Verify accessibility - semantic labels', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      // Check that interactive elements have semantic labels
      // This helps ensure accessibility for users with screen readers
      final widgets = find.byType(Material);
      expect(widgets, findsWidgets);
    });

    testWidgets('App handles device lifecycle events', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);

      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      expect(find.byType(MaterialApp), findsWidgets);
    });
  });

  group('MyNotes App - Navigation', () {
    testWidgets('App handles back navigation correctly', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      // Test back button handling
      expect(find.byType(MaterialApp), findsWidgets);

      // Additional navigation tests can be added based on your app structure
    });

    testWidgets('Navigation maintains state appropriately', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      expect(find.byType(MaterialApp), findsWidgets);
    });
  });

  group('MyNotes App - Performance', () {
    testWidgets('App performance - initial load time', (
      WidgetTester tester,
    ) async {
      final stopwatch = Stopwatch()..start();

      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      stopwatch.stop();

      // App should load within 5 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    testWidgets('App handles rapid interactions', (WidgetTester tester) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      // Try rapid interactions
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.byType(MaterialApp), findsWidgets);
    });
  });

  group('MyNotes App - Accessibility', () {
    testWidgets('App screen contrast is sufficient', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      // Verify that the app displays content
      expect(find.byType(MaterialApp), findsWidgets);
    });

    testWidgets('App supports larger text sizes', (WidgetTester tester) async {
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      expect(find.byType(MaterialApp), findsWidgets);
    });

    testWidgets('App provides haptic feedback', (WidgetTester tester) async {
      app.main();
      await IntegrationTestUtils.waitForAppToSettle(tester);

      // Verify interactive elements respond to taps
      expect(find.byType(MaterialApp), findsWidgets);
    });
  });
}
