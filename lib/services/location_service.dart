// FILE: lib/services/location_service.dart
// FUNGSI: Mengambil posisi pengguna menggunakan geolocator
// CARA KERJA:
// 1. Memeriksa izin lokasi (granted, denied, permanently denied)
// 2. Memeriksa layanan GPS (aktif/tidak)
// 3. Mengembalikan LocationResult (sealed)
// 4. Tidak pernah crash, selalu return nilai
// 5. Semua error ditangkap dan dikonversi ke LocationResult

import 'package:geolocator/geolocator.dart';
import '../models/location_result.dart';

class LocationService {
  Future<LocationResult> getCurrentLocation() async {
    try {
      final permission = await _checkPermission();
      
      if (permission == LocationPermission.denied) {
        return const LocationDenied(
          message: 'Izin lokasi ditolak. Aplikasi tetap berjalan tanpa urutan jarak.',
        );
      }
      
      if (permission == LocationPermission.deniedForever) {
        return const LocationPermanentlyDenied(
          message: 'Izin lokasi ditolak permanen. Buka pengaturan untuk mengaktifkan.',
        );
      }

      final isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled) {
        return const LocationUnavailable(
          message: 'GPS mati. Aktifkan GPS untuk urutan jarak terbaik.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      return LocationSuccess(position);
      
    } catch (e) {
      return LocationUnavailable(
        message: 'Gagal mendapatkan lokasi: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    }
  }

  Future<LocationPermission> _checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always ||
        permission == LocationPermission.unableToDetermine) {
      return permission;
    }
    
    permission = await Geolocator.requestPermission();
    return permission;
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}