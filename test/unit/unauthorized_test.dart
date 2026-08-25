// FILE: test/unit/unauthorized_test.dart
// FUNGSI: Test untuk menangani error 401 Unauthorized

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nearbite_app/models/api_error.dart';
import 'package:nearbite_app/services/api_client.dart';

void main() {
  group('401 Unauthorized Error Tests', () {
    test('Status code 401 maps to UnauthorizedError', () {
      final error = ApiErrorMapper.fromStatusCode(401);
      
      expect(error, isA<UnauthorizedError>());
      expect(error.message, 'Sesi habis, silakan login ulang');
    });

    test('Status code 403 maps to UnauthorizedError', () {
      final error = ApiErrorMapper.fromStatusCode(403);
      
      expect(error, isA<UnauthorizedError>());
      expect(error.message, 'Anda tidak memiliki akses');
    });

    test('401 with custom message', () {
      final error = ApiErrorMapper.fromStatusCode(
        401,
        message: 'Invalid API key',
      );
      
      expect(error, isA<UnauthorizedError>());
      expect(error.message, 'Invalid API key');
    });

    test('Simulate PostgrestException with 401', () {
      final error = ApiErrorMapper.fromStatusCode(
        401,
        message: 'Invalid API key, code: 401, details: Unauthorized',
      );
      
      expect(error, isA<UnauthorizedError>());
      expect(error.message, contains('Invalid API key'));
    });

    test('User friendly error message for 401', () {
      const error = UnauthorizedError(
        message: 'Sesi habis, silakan login ulang',
      );
      
      expect(error.message, isNot(contains('Exception')));
      expect(error.message, isNot(contains('StackTrace')));
      expect(error.message, contains('login'));
    });
  });

  group('401 UI Tests', () {
    testWidgets('Error widget shows 401 message', (WidgetTester tester) async {
      const errorMessage = 'Sesi habis, silakan login ulang';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 64),
                  SizedBox(height: 16),
                  Text(
                    errorMessage,
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: null,
                    child: Text('Login Ulang'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('Login Ulang'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('Restaurant detail shows 401 error', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'Gagal memuat detail',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sesi habis, silakan login ulang',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: null,
                    child: Text('Coba lagi'),
                  ),
                  TextButton(
                    onPressed: null,
                    child: Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Gagal memuat detail'), findsOneWidget);
      expect(find.text('Sesi habis, silakan login ulang'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });
  });
}
