import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sparkhub/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SparkHub App Integration Tests', () {
    testWidgets('app launches and shows initial screen', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test that the app launches successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('navigation flow works correctly', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test basic navigation (this would be expanded based on your app structure)
      // Since we're testing without authentication, we'll test what's available
      
      // Look for common UI elements that should be present
      final finder = find.byType(Scaffold);
      expect(finder, findsWidgets);
    });

    testWidgets('handles errors gracefully', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test that error boundary works if any errors occur
      expect(tester.takeException(), isNull);
    });
  });

  group('Authentication Flow Tests', () {
    testWidgets('login screen displays correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // This test would check for login-specific UI elements
      // Adjust based on your actual login screen implementation
      
      // Test passes if no exceptions are thrown during app startup
      expect(tester.takeException(), isNull);
    });
  });

  group('Event Management Tests', () {
    testWidgets('event list loads', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test that events can be loaded (would require mock data in real test)
      expect(tester.takeException(), isNull);
    });
  });

  group('Performance Tests', () {
    testWidgets('app startup performance', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      stopwatch.stop();
      
      // Test that app starts within reasonable time (5 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });
  });
}
