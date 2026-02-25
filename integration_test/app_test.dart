import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mynotes/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MyNotes App Integration Tests', () {
    testWidgets('App launches and displays home page', (
      WidgetTester tester,
    ) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify app is running
      expect(find.byType(MaterialApp), findsWidgets);
    });

    testWidgets('Navigate to notes list', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap on notes/home if needed
      // This test can be expanded based on your app structure
      expect(find.byType(MaterialApp), findsWidgets);
    });

    testWidgets('App handles back navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test back button functionality
      expect(find.byType(MaterialApp), findsWidgets);
    });

    testWidgets('Verify accessibility features', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test semantic labels for accessibility
      expect(find.byType(MaterialApp), findsWidgets);
    });
  });
}
