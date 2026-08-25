// ============================================================
// UNIT 3: Sorting Restoran Berdasarkan Jarak
// FILE: lib/utils/sort_utils.dart
// ============================================================
// CARA KERJA:
// 1. Mengurutkan daftar restoran dari yang terdekat
// 2. Menggunakan fungsi Haversine untuk menghitung jarak
// 3. Fungsi PURE - MUDAH DI-TEST
// 4. Dipisah dari UI agar bisa di-unit-test (requirement B)
// ============================================================

import '../models/restaurant_model.dart';
import 'distance_utils.dart';

// ============================================================
// FUNGSI: sortRestaurantsByDistance()
// CARA KERJA:
// 1. Terima daftar restoran dan posisi pengguna (userLat, userLon)
// 2. Buat salinan list agar TIDAK mengubah data asli (immutable)
// 3. Untuk setiap pasangan restoran (a, b), hitung jarak masing-masing
// 4. Bandingkan jarak: yang lebih kecil diletakkan di DEPAN (ascending)
// 5. Kembalikan list yang sudah terurut dari terdekat ke terjauh
// 6. Digunakan di HomeScreen untuk menampilkan resto terdekat
// ============================================================
List<RestaurantModel> sortRestaurantsByDistance(
  List<RestaurantModel> restaurants,
  double userLat,
  double userLon,
) {
  // Buat salinan agar tidak mengubah data asli
  final sorted = List<RestaurantModel>.from(restaurants);

  // Sorting dengan pembanding jarak
  sorted.sort((a, b) {
    // Hitung jarak restoran a dari posisi pengguna
    final distanceA = calculateDistance(
      userLat,
      userLon,
      a.latitude,
      a.longitude,
    );
    
    // Hitung jarak restoran b dari posisi pengguna
    final distanceB = calculateDistance(
      userLat,
      userLon,
      b.latitude,
      b.longitude,
    );
    
    // Bandingkan: jika distanceA < distanceB, maka a di depan b
    return distanceA.compareTo(distanceB);
  });

  return sorted;
}

// ============================================================
// FUNGSI: addDistanceToRestaurants()
// CARA KERJA:
// 1. Terima daftar restoran dan posisi pengguna
// 2. Untuk setiap restoran, hitung jarak dari posisi pengguna
// 3. Buat Map dengan 3 key: 'restaurant', 'distance', 'distanceText'
// 4. Kembalikan List<Map> untuk digunakan di UI
// 5. Berguna untuk menampilkan jarak di kartu restoran
// ============================================================
List<Map<String, dynamic>> addDistanceToRestaurants(
  List<RestaurantModel> restaurants,
  double userLat,
  double userLon,
) {
  return restaurants.map((restaurant) {
    final distance = calculateDistance(
      userLat,
      userLon,
      restaurant.latitude,
      restaurant.longitude,
    );
    return {
      'restaurant': restaurant,
      'distance': distance,
      'distanceText': formatDistance(distance),
    };
  }).toList();
}

// ============================================================
// FUNGSI: filterRestaurantsByRadius()
// CARA KERJA:
// 1. Terima daftar restoran, posisi pengguna, dan radius (km)
// 2. Untuk setiap restoran, hitung jarak dari posisi pengguna
// 3. Jika jarak <= radius, masukkan ke hasil
// 4. Kembalikan daftar restoran yang berada dalam radius
// 5. Berguna untuk fitur "restoran dalam radius 5 km"
// ============================================================
List<RestaurantModel> filterRestaurantsByRadius(
  List<RestaurantModel> restaurants,
  double userLat,
  double userLon,
  double radiusKm,
) {
  return restaurants.where((restaurant) {
    final distance = calculateDistance(
      userLat,
      userLon,
      restaurant.latitude,
      restaurant.longitude,
    );
    return distance <= radiusKm;
  }).toList();
}

// ============================================================
// FUNGSI: findNearestRestaurant()
// CARA KERJA:
// 1. Jika daftar kosong, return null
// 2. Ambil restoran pertama sebagai kandidat terdekat
// 3. Iterasi semua restoran, bandingkan jarak masing-masing
// 4. Jika jarak lebih kecil, update kandidat
// 5. Return restoran dengan jarak terkecil
// ============================================================
RestaurantModel? findNearestRestaurant(
  List<RestaurantModel> restaurants,
  double userLat,
  double userLon,
) {
  if (restaurants.isEmpty) return null;

  RestaurantModel nearest = restaurants.first;
  double nearestDistance = calculateDistance(
    userLat,
    userLon,
    nearest.latitude,
    nearest.longitude,
  );

  for (final restaurant in restaurants) {
    final distance = calculateDistance(
      userLat,
      userLon,
      restaurant.latitude,
      restaurant.longitude,
    );
    if (distance < nearestDistance) {
      nearestDistance = distance;
      nearest = restaurant;
    }
  }

  return nearest;
}

// ============================================================
// FUNGSI: calculateAverageDistance()
// CARA KERJA:
// 1. Jika daftar kosong, return 0.0
// 2. Jumlahkan semua jarak dari posisi pengguna ke setiap restoran
// 3. Bagi total dengan jumlah restoran
// 4. Return jarak rata-rata (double)
// ============================================================
double calculateAverageDistance(
  List<RestaurantModel> restaurants,
  double userLat,
  double userLon,
) {
  if (restaurants.isEmpty) return 0.0;

  double totalDistance = 0.0;
  for (final restaurant in restaurants) {
    totalDistance += calculateDistance(
      userLat,
      userLon,
      restaurant.latitude,
      restaurant.longitude,
    );
  }
  return totalDistance / restaurants.length;
}