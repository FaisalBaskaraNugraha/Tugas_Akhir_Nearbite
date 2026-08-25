// 
// UNIT 8: Unit Test - Haversine & Sorting
// FILE: test/distance_test.dart
// 
// CARA KERJA:
// 1. Menguji kebenaran fungsi Haversine dan sorting
// 2. Test 1-5: Verifikasi akurasi perhitungan jarak
// 3. Test 6-11: Verifikasi format tampilan jarak
// 4. Test 12-16: Verifikasi sorting dan filtering
// 5. Semua test INDEPENDEN, tidak bergantung jaringan/internet
// 6. Menggunakan mock data, bukan server sungguhan
// 7. JUMLAH: 16 unit test (≥3 sesuai requirement)
// 

import 'package:flutter_test/flutter_test.dart';
import 'package:nearbite_app/models/restaurant_model.dart';
import 'package:nearbite_app/utils/distance_utils.dart';
import 'package:nearbite_app/utils/sort_utils.dart';

void main() {
  // 
  // GROUP 1: HAVERSINE DISTANCE ACCURACY (Test 1-5)
  // 
  // CARA KERJA:
  // 1. Test 1: Jarak ke titik yang sama harus 0
  // 2. Test 2: Jarak Semarang-Jakarta sekitar 450 km
  // 3. Test 3: Jarak Semarang-Surabaya sekitar 260 km
  // 4. Test 4: Jarak 2 restoran di Semarang sekitar 0.23 km
  // 5. Test 5: Jarak 2 restoran di Semarang sekitar 0.8 km
  // 
  
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

    test('Jarak Semarang - Surabaya sekitar 260 km', () {
      const double surabayaLat = -7.257500;
      const double surabayaLon = 112.752100;

      final distance = calculateDistance(
        semarangLat,
        semarangLon,
        surabayaLat,
        surabayaLon,
      );

      expect(distance, greaterThan(240));
      expect(distance, lessThan(280));
    });

    test('Jarak dua restoran di Semarang sekitar 0.23 km', () {
      const lat1 = -6.979026;
      const lon1 = 110.411453;
      const lat2 = -6.980964;
      const lon2 = 110.410440;

      final distance = calculateDistance(lat1, lon1, lat2, lon2);

      expect(distance, greaterThan(0.1));
      expect(distance, lessThan(0.5));
    });

    test('Jarak Masa Kitchen - Wasabi Sushi sekitar 0.8 km', () {
      const lat1 = -6.979026;
      const lon1 = 110.411453;
      const lat2 = -6.982296;
      const lon2 = 110.404482;

      final distance = calculateDistance(lat1, lon1, lat2, lon2);

      expect(distance, greaterThan(0.5));
      expect(distance, lessThan(1.2));
    });

    // 
    // GROUP 2: DISTANCE FORMATTING (Test 6-11)
    // 
    // CARA KERJA:
    // 1. Test 6: 0 km → "0 m"
    // 2. Test 7: 0.05 km → "50 m"
    // 3. Test 8: 0.095 km → "95 m"
    // 4. Test 9: 0.5 km → "500 m"
    // 5. Test 10: 1.2 km → "1.2 km"
    // 6. Test 11: 10.5 km → "10.5 km"
    // 
    
    test('Format jarak - 0 meter', () {
      expect(formatDistance(0.0), '0 m');
    });

    test('Format jarak - 50 meter', () {
      expect(formatDistance(0.05), '50 m');
    });

    test('Format jarak - 95 meter', () {
      expect(formatDistance(0.095), '95 m');
    });

    test('Format jarak - 500 meter', () {
      expect(formatDistance(0.5), '500 m');
    });

    test('Format jarak - 1.2 km', () {
      expect(formatDistance(1.2), '1.2 km');
    });

    test('Format jarak - 10.5 km', () {
      expect(formatDistance(10.5), '10.5 km');
    });
  });

  // 
  // GROUP 3: SORTING AND FILTERING (Test 12-16)
  // 
  // CARA KERJA:
  // 1. Buat mock data dengan 3 restoran: Jauh, Dekat, Sedang
  // 2. Test 12: Sorting dari terdekat ke terjauh
  // 3. Test 13: Filter dalam radius 10 km
  // 4. Test 14: Menambahkan field jarak
  // 5. Test 15: Menemukan restoran terdekat
  // 6. Test 16: Menghitung jarak rata-rata
  // 
  
  group('Sorting Tests', () {
    final DateTime now = DateTime.now();

    final List<RestaurantModel> restaurants = [
      RestaurantModel(
        id: '1',
        ownerId: 'owner1',
        name: 'Jauh',
        description: 'Restoran jauh',
        address: 'Jl. Jauh',
        latitude: -7.5,
        longitude: 111.0,
        openHours: '10:00-22:00',
        createdAt: now,
        updatedAt: now,
      ),
      RestaurantModel(
        id: '2',
        ownerId: 'owner1',
        name: 'Dekat',
        description: 'Restoran dekat',
        address: 'Jl. Dekat',
        latitude: -6.98,
        longitude: 110.41,
        openHours: '10:00-22:00',
        createdAt: now,
        updatedAt: now,
      ),
      RestaurantModel(
        id: '3',
        ownerId: 'owner1',
        name: 'Sedang',
        description: 'Restoran sedang',
        address: 'Jl. Sedang',
        latitude: -6.95,
        longitude: 110.40,
        openHours: '10:00-22:00',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    test('Sort restoran dari terdekat ke terjauh', () {
      const userLat = -6.979026;
      const userLon = 110.411453;

      final sorted = sortRestaurantsByDistance(restaurants, userLat, userLon);

      expect(sorted[0].name, 'Dekat');
      expect(sorted[1].name, 'Sedang');
      expect(sorted[2].name, 'Jauh');
    });

    test('Filter restoran dalam radius 10 km', () {
      const userLat = -6.979026;
      const userLon = 110.411453;

      final filtered = filterRestaurantsByRadius(
        restaurants,
        userLat,
        userLon,
        10.0,
      );

      expect(filtered.length, 2);
      expect(filtered.any((r) => r.name == 'Dekat'), true);
      expect(filtered.any((r) => r.name == 'Sedang'), true);
      expect(filtered.any((r) => r.name == 'Jauh'), false);
    });

    test('Add distance to restaurants', () {
      const userLat = -6.979026;
      const userLon = 110.411453;

      final result = addDistanceToRestaurants(restaurants, userLat, userLon);

      expect(result.length, 3);
      expect(result[0]['distance'], isA<double>());
      expect(result[0]['distanceText'], isA<String>());
      expect(result[0]['restaurant'], isA<RestaurantModel>());

      final dekatDistance = result.firstWhere(
        (item) => (item['restaurant'] as RestaurantModel).name == 'Dekat',
      )['distance'] as double;

      final sedangDistance = result.firstWhere(
        (item) => (item['restaurant'] as RestaurantModel).name == 'Sedang',
      )['distance'] as double;

      final jauhDistance = result.firstWhere(
        (item) => (item['restaurant'] as RestaurantModel).name == 'Jauh',
      )['distance'] as double;

      expect(dekatDistance, lessThan(sedangDistance));
      expect(sedangDistance, lessThan(jauhDistance));
    });

    test('Find nearest restaurant', () {
      const userLat = -6.979026;
      const userLon = 110.411453;

      final nearest = findNearestRestaurant(restaurants, userLat, userLon);

      expect(nearest, isNotNull);
      expect(nearest!.name, 'Dekat');
    });

    test('Calculate average distance', () {
      const userLat = -6.979026;
      const userLon = 110.411453;

      final average = calculateAverageDistance(
        restaurants,
        userLat,
        userLon,
      );

      expect(average, greaterThan(0));
      expect(average, lessThan(100));
    });
  });
}