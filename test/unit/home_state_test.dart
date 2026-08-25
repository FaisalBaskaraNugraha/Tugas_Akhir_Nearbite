// FILE: test/unit/home_state_test.dart
// FUNGSI: Widget test untuk state UI HomeScreen

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nearbite_app/screens/home/home_screen.dart';

void main() {
  group('HomeScreen State Tests', () {
    testWidgets('HomeScreen - loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('HomeScreen - search bar exists', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Pump once to build initial state
      await tester.pump();

      // Search bar should exist
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
    });
  });
}