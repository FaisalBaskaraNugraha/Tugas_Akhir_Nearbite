// FILE: test/unit/haversine_test.dart
// FUNGSI: Unit test untuk Haversine

import 'package:flutter_test/flutter_test.dart';
import 'package:nearbite_app/utils/distance_utils.dart';

void main() {
  group('Haversine Distance Tests', () {
    const double semarangLat = -6.979026;
    const double semarangLon = 110.411453;

    test('Jarak ke titik yang sama = 0', () {
      final distance = calculateDistance(
        semarangLat,
        semarangLon,
        semarangLat,
        semarangLon,
      );
      expect(distance, 0.0);
    });

    test('Jarak Semarang - Jakarta sekitar 450 km', () {
      const double jakartaLat = -6.200000;
      const double jakartaLon = 106.816666;

      final distance = calculateDistance(
        semarangLat,
        semarangLon,
        jakartaLat,
        jakartaLon,
      );

      expect(distance, greaterThan(400));
      expect(distance, lessThan(550));
    });

    test('Format jarak - 0 meter', () {
      expect(formatDistance(0.0), '0 m');
    });

    test('Format jarak - 500 meter', () {
      expect(formatDistance(0.5), '500 m');
    });

    test('Format jarak - 1.2 km', () {
      expect(formatDistance(1.2), '1.2 km');
    });
  });
}