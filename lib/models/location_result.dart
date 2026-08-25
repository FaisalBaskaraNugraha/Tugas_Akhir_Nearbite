// FILE: lib/models/location_result.dart
// FUNGSI: Sealed class untuk menangani hasil akses lokasi
// CARA KERJA:
// 1. LocationSuccess: lokasi berhasil didapat
// 2. LocationDenied: user menolak izin
// 3. LocationUnavailable: GPS mati / layanan tidak tersedia
// 4. LocationPermanentlyDenied: user menolak permanen
// 5. Semua case ditangani exhaustive (switch harus lengkap)

import 'package:geolocator/geolocator.dart';

sealed class LocationResult {
  const LocationResult();
}

class LocationSuccess extends LocationResult {
  final Position position;
  const LocationSuccess(this.position);

  double get latitude => position.latitude;
  double get longitude => position.longitude;
}

class LocationDenied extends LocationResult {
  final String message;
  const LocationDenied({this.message = 'Izin lokasi ditolak'});
}

class LocationUnavailable extends LocationResult {
  final String message;
  const LocationUnavailable({this.message = 'Layanan lokasi tidak tersedia'});
}

class LocationPermanentlyDenied extends LocationResult {
  final String message;
  const LocationPermanentlyDenied({
    this.message = 'Izin lokasi ditolak permanen. Buka pengaturan untuk mengaktifkan.',
  });
}