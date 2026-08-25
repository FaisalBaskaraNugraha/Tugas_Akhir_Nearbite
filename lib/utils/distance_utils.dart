// ============================================================
// UNIT 2: Haversine Formula
// FILE: lib/utils/distance_utils.dart
// ============================================================
// CARA KERJA:
// 1. Menghitung jarak antara dua titik koordinat di bumi
// 2. Menggunakan rumus Haversine - standar untuk jarak pendek hingga sedang
// 3. Fungsi PURE (tidak bergantung state/context) - MUDAH DI-TEST
// 4. Dipisah dari UI agar bisa di-unit-test (requirement B)
// ============================================================

import 'dart:math';

// ============================================================
// FUNGSI: calculateDistance()
// CARA KERJA:
// 1. Terima 4 parameter: lat1, lon1, lat2, lon2 (semua dalam derajat)
// 2. Konversi derajat ke radian (fungsi trigonometri math pakai radian)
// 3. Hitung selisih latitude (dLat) dan longitude (dLon) dalam radian
// 4. Terapkan rumus Haversine:
//    a = sin²(dlat/2) + cos(lat1) * cos(lat2) * sin²(dlon/2)
//    c = 2 * atan2(√a, √(1-a))
//    jarak = radius_bumi * c (radius bumi = 6371 km)
// 5. Kembalikan jarak dalam kilometer (double)
// ============================================================
double calculateDistance(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  // Radius bumi dalam kilometer (konstanta)
  const double earthRadius = 6371.0;

  // STEP 1: Konversi selisih derajat ke radian
  final double dLat = _toRadians(lat2 - lat1);
  final double dLon = _toRadians(lon2 - lon1);

  // STEP 2: Rumus Haversine - hitung nilai 'a'
  final double a = pow(sin(dLat / 2), 2) +
      cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
      pow(sin(dLon / 2), 2);

  // STEP 3: Hitung nilai 'c' (jarak sudut dalam radian)
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  // STEP 4: Jarak = radius_bumi * c (dalam kilometer)
  return earthRadius * c;
}

// ============================================================
// FUNGSI: _toRadians()
// CARA KERJA:
// 1. Fungsi pembantu untuk konversi derajat ke radian
// 2. Rumus: radian = derajat * π / 180
// 3. Dipakai internal oleh calculateDistance()
// ============================================================
double _toRadians(double degree) {
  return degree * pi / 180;
}

// ============================================================
// FUNGSI: formatDistance()
// CARA KERJA:
// 1. Mengubah jarak (km) menjadi string yang mudah dibaca manusia
// 2. Jika < 100 meter → tampilkan dalam meter (contoh: "50 m")
// 3. Jika < 1 km → tampilkan dalam meter (contoh: "500 m")
// 4. Jika >= 1 km → tampilkan dalam km dengan 1 desimal (contoh: "1.2 km")
// 5. Dipakai di UI untuk menampilkan jarak ke pengguna
// ============================================================
String formatDistance(double distanceInKm) {
  if (distanceInKm < 0.1) {
    final int meters = (distanceInKm * 1000).round();
    return '$meters m';
  } else if (distanceInKm < 1) {
    final int meters = (distanceInKm * 1000).round();
    return '$meters m';
  } else {
    return '${distanceInKm.toStringAsFixed(1)} km';
  }
}