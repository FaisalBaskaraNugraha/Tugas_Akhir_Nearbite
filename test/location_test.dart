import 'package:flutter_test/flutter_test.dart';
import 'package:nearbite_app/models/location_result.dart';

void main() {
  group('LocationResult Sealed Class Tests', () {
    test('LocationDenied - has message', () {
      const result = LocationDenied(message: 'Izin lokasi ditolak');
      expect(result.message, 'Izin lokasi ditolak');
    });

    test('LocationPermanentlyDenied - has message', () {
      const result = LocationPermanentlyDenied(
        message: 'Izin ditolak permanen',
      );
      expect(result.message, 'Izin ditolak permanen');
    });

    test('LocationUnavailable - has message', () {
      const result = LocationUnavailable(message: 'GPS mati');
      expect(result.message, 'GPS mati');
    });
  });
}