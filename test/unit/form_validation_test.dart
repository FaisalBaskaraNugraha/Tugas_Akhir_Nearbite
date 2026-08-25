// FILE: test/widget/form_validation_test.dart
// FUNGSI: Widget test untuk validasi form menu

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nearbite_app/screens/owner/add_menu_screen.dart';

void main() {
  group('Form Validation Widget Tests', () {
    testWidgets('AddMenuScreen - empty name shows error', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddMenuScreen(restaurantId: 'test-id'),
        ),
      );

      // Find save button
      final saveButton = find.text('Simpan Menu');
      expect(saveButton, findsOneWidget);

      // Tap save without filling name
      await tester.tap(saveButton);
      await tester.pump();

      // Error message should appear
      expect(find.text('Nama menu harus diisi'), findsOneWidget);
    });

    testWidgets('AddMenuScreen - invalid price shows error', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddMenuScreen(restaurantId: 'test-id'),
        ),
      );

      // Fill name
      final nameField = find.widgetWithText(TextFormField, 'Nama Menu *');
      await tester.enterText(nameField, 'Nasi Goreng');

      // Fill invalid price
      final priceField = find.widgetWithText(TextFormField, 'Harga (Rp) *');
      await tester.enterText(priceField, 'abc');

      // Tap save
      final saveButton = find.text('Simpan Menu');
      await tester.tap(saveButton);
      await tester.pump();

      // Error message should appear
      expect(find.text('Harga harus berupa angka'), findsOneWidget);
    });

    testWidgets('AddMenuScreen - valid form submits', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddMenuScreen(restaurantId: 'test-id'),
        ),
      );

      // Fill name
      final nameField = find.widgetWithText(TextFormField, 'Nama Menu *');
      await tester.enterText(nameField, 'Nasi Goreng');

      // Fill price
      final priceField = find.widgetWithText(TextFormField, 'Harga (Rp) *');
      await tester.enterText(priceField, '25000');

      // Tap save
      final saveButton = find.text('Simpan Menu');
      await tester.tap(saveButton);
      await tester.pump();

      // No error message should appear
      expect(find.text('Nama menu harus diisi'), findsNothing);
      expect(find.text('Harga harus berupa angka'), findsNothing);
    });
  });
}
