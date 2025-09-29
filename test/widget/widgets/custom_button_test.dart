import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparkhub/utils/constants/colors.dart';
import 'package:sparkhub/widgets/common/custom_button.dart';

void main() {
  group('CustomButton Widget Tests', () {
    testWidgets('should display button text', (WidgetTester tester) async {
      const buttonText = 'Test Button';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: buttonText,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text(buttonText), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Test Button',
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CustomButton));
      expect(wasPressed, true);
    });

    testWidgets('should show loading indicator when isLoading is true', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Test Button',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Test Button'), findsNothing);
    });

    testWidgets('should be disabled when onPressed is null', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Test Button',
              onPressed: null,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, null);
    });

    testWidgets('should display icon when provided', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Test Button',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should apply gradient colors correctly', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Gradient Button',
              type: ButtonType.gradient,
              gradientColors: AppColors.primaryGradient,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Gradient Button'), findsOneWidget);
    });

    testWidgets('should handle different button sizes', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CustomButton(
                  text: 'Small Button',
                  size: ButtonSize.small,
                  onPressed: () {},
                ),
                CustomButton(
                  text: 'Medium Button',
                  size: ButtonSize.medium,
                  onPressed: () {},
                ),
                CustomButton(
                  text: 'Large Button',
                  size: ButtonSize.large,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Small Button'), findsOneWidget);
      expect(find.text('Medium Button'), findsOneWidget);
      expect(find.text('Large Button'), findsOneWidget);
    });

    testWidgets('should handle full width button', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Full Width Button',
              isFullWidth: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Full Width Button'), findsOneWidget);
      
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(Container),
        ).first,
      );
      
      expect(container.constraints?.maxWidth, double.infinity);
    });

    testWidgets('should handle outline button type', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Outline Button',
              type: ButtonType.outline,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Outline Button'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('should handle text button type', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Text Button',
              type: ButtonType.text,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Text Button'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });
  });
}
