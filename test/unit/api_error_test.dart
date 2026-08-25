// FILE: test/unit/api_error_test.dart
// FUNGSI: Unit test untuk ApiError mapping

import 'package:flutter_test/flutter_test.dart';
import 'package:nearbite_app/models/api_error.dart';

void main() {
  group('ApiError Tests', () {
    test('NetworkError has message', () {
      const error = NetworkError(message: 'No internet');
      expect(error.message, 'No internet');
    });

    test('UnauthorizedError has message', () {
      const error = UnauthorizedError(message: 'Token expired');
      expect(error.message, 'Token expired');
    });

    test('NotFoundError has message', () {
      const error = NotFoundError(message: 'Not found');
      expect(error.message, 'Not found');
    });

    test('ValidationError has message and statusCode', () {
      const error = ValidationError(
        message: 'Invalid input',
        statusCode: 400,
      );
      expect(error.message, 'Invalid input');
      expect(error.statusCode, 400);
    });

    test('ServerError has message and statusCode', () {
      const error = ServerError(
        message: 'Server down',
        statusCode: 500,
      );
      expect(error.message, 'Server down');
      expect(error.statusCode, 500);
    });
  });
}