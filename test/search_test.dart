// ============================================================
// UNIT 9: Unit Test - Search
// FILE: test/search_test.dart
// ============================================================
// CARA KERJA:
// 1. Menguji kebenaran fungsi pencarian restoran
// 2. Test 1: Cari berdasarkan nama restoran (case-insensitive)
// 3. Test 2: Cari berdasarkan nama menu (case-insensitive)
// 4. Test 3: Cari dengan partial query
// 5. Test 4: Empty query returns all
// 6. Test 5: Query no match returns empty
// 7. Test 6: Search dengan spasi
// 8. Test 7: Search returns multiple restaurants
// 9. Semua test INDEPENDEN, tidak bergantung jaringan
// 10. JUMLAH: 7 unit test
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:nearbite_app/models/restaurant_model.dart';
import 'package:nearbite_app/models/menu_item_model.dart';

void main() {
  group('Search Logic Tests', () {
    // ============================================================
    // MOCK DATA
    // ============================================================
    final DateTime now = DateTime.now();

    final restaurants = [
      RestaurantModel(
        id: '1',
        ownerId: 'owner1',
        name: 'Masa Kitchen',
        description: 'Bubur, sup, ayam',
        address: 'Jl. Imam Bonjol',
        latitude: -6.979026,
        longitude: 110.411453,
        openHours: '11:00-21:00',
        createdAt: now,
        updatedAt: now,
      ),
      RestaurantModel(
        id: '2',
        ownerId: 'owner1',
        name: 'Waroeng Steak',
        description: 'Steak berbagai pilihan',
        address: 'Jl. Imam Bonjol',
        latitude: -6.980964,
        longitude: 110.410440,
        openHours: '11:00-22:00',
        createdAt: now,
        updatedAt: now,
      ),
      RestaurantModel(
        id: '3',
        ownerId: 'owner1',
        name: 'Wasabi Sushi',
        description: 'Wasabi, sushi, ramen',
        address: 'Jl. Mgr Sugiyopranoto',
        latitude: -6.982296,
        longitude: 110.404482,
        openHours: '11:00-21:30',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    final menuItems = [
      MenuItemModel(
        id: '1',
        restaurantId: '1',
        name: 'Bubur Ayam Special',
        description: 'Bubur ayam dengan suwiran ayam',
        price: 22000,
        isAvailable: true,
        createdAt: now,
      ),
      MenuItemModel(
        id: '2',
        restaurantId: '1',
        name: 'Sup Ayam Bening',
        description: 'Sup ayam bening dengan sayuran',
        price: 25000,
        isAvailable: true,
        createdAt: now,
      ),
      MenuItemModel(
        id: '3',
        restaurantId: '3',
        name: 'Sushi Salmon',
        description: 'Nigiri sushi dengan salmon segar',
        price: 35000,
        isAvailable: true,
        createdAt: now,
      ),
      MenuItemModel(
        id: '4',
        restaurantId: '3',
        name: 'Ramen Tonkotsu',
        description: 'Ramen dengan kuah tulang babi',
        price: 42000,
        isAvailable: true,
        createdAt: now,
      ),
    ];

    // ============================================================
    // FUNGSI SEARCH MANUAL (SIMULASI)
    // CARA KERJA:
    // 1. Jika query kosong, kembalikan semua restoran
    // 2. Untuk setiap restoran, cek apakah nama resto mengandung query
    // 3. Atau cek apakah ada menu dengan nama mengandung query
    // 4. Case-insensitive menggunakan toLowerCase()
    // ============================================================
    List<RestaurantModel> searchRestaurants(
      List<RestaurantModel> restaurants,
      List<MenuItemModel> menuItems,
      String query,
    ) {
      if (query.trim().isEmpty) return restaurants;

      final lowerQuery = query.toLowerCase().trim();

      return restaurants.where((restaurant) {
        // Cari di nama resto
        if (restaurant.name.toLowerCase().contains(lowerQuery)) {
          return true;
        }

        // Cari di nama menu
        final hasMatchingMenu = menuItems.any((menu) =>
            menu.restaurantId == restaurant.id &&
            menu.name.toLowerCase().contains(lowerQuery));

        return hasMatchingMenu;
      }).toList();
    }

    // ============================================================
    // TEST 1: Search by restaurant name
    // ============================================================
    test('Search by restaurant name - case insensitive', () {
      final results = searchRestaurants(restaurants, menuItems, 'masa');
      expect(results.length, 1);
      expect(results[0].name, 'Masa Kitchen');

      final results2 = searchRestaurants(restaurants, menuItems, 'STEAK');
      expect(results2.length, 1);
      expect(results2[0].name, 'Waroeng Steak');

      final results3 = searchRestaurants(restaurants, menuItems, 'sushi');
      expect(results3.length, 1);
      expect(results3[0].name, 'Wasabi Sushi');
    });

    // ============================================================
    // TEST 2: Search by menu name
    // ============================================================
    test('Search by menu name - case insensitive', () {
      final results = searchRestaurants(restaurants, menuItems, 'bubur');
      expect(results.length, 1);
      expect(results[0].name, 'Masa Kitchen');

      final results2 = searchRestaurants(restaurants, menuItems, 'salmon');
      expect(results2.length, 1);
      expect(results2[0].name, 'Wasabi Sushi');

      final results3 = searchRestaurants(restaurants, menuItems, 'ramen');
      expect(results3.length, 1);
      expect(results3[0].name, 'Wasabi Sushi');
    });

    // ============================================================
    // TEST 3: Search with partial query
    // ============================================================
    test('Search with partial query', () {
      final results = searchRestaurants(restaurants, menuItems, 'ma');
      expect(results.length, 1);
      expect(results[0].name, 'Masa Kitchen');

      final results2 = searchRestaurants(restaurants, menuItems, 'wa');
      expect(results2.length, 2);
      expect(results2.any((r) => r.name == 'Waroeng Steak'), true);
      expect(results2.any((r) => r.name == 'Wasabi Sushi'), true);
    });

    // ============================================================
    // TEST 4: Empty query returns all
    // ============================================================
    test('Empty query returns all restaurants', () {
      final results = searchRestaurants(restaurants, menuItems, '');
      expect(results.length, 3);
    });

    // ============================================================
    // TEST 5: Query with no match
    // ============================================================
    test('Query with no match returns empty list', () {
      final results = searchRestaurants(restaurants, menuItems, 'xyz123');
      expect(results.length, 0);
    });

    // ============================================================
    // TEST 6: Search with spaces
    // ============================================================
    test('Search by restaurant name with spaces', () {
      final results = searchRestaurants(restaurants, menuItems, 'masa kitchen');
      expect(results.length, 1);
      expect(results[0].name, 'Masa Kitchen');
    });

    // ============================================================
    // TEST 7: Search returns multiple restaurants
    // ============================================================
    test('Search returns multiple restaurants', () {
      final results = searchRestaurants(restaurants, menuItems, 'wa');
      expect(results.length, 2);
      expect(results.any((r) => r.name == 'Waroeng Steak'), true);
      expect(results.any((r) => r.name == 'Wasabi Sushi'), true);
    });
  });
}