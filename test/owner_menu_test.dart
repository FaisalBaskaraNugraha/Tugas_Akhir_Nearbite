// 
// UNIT: Owner & Menu CRUD Tests
// FILE: test/owner_menu_test.dart
// 
// CARA KERJA:
// 1. Menguji logika CRUD restoran dan menu tanpa jaringan
// 2. Test 1: Validasi form nama restoran
// 3. Test 2: Validasi form koordinat
// 4. Test 3: Validasi form harga menu
// 5. Test 4: RestaurantModel fromJson dan toJson
// 6. Test 5: RestaurantModel copyWith
// 7. Test 6: MenuItemModel fromJson
// 8. Test 7: MenuItemModel priceFormatted
// 9. Test 8: MenuItemModel copyWith
// 10. Test 9: Validasi nama menu
// 11. Test 10: Filter menu berdasarkan ketersediaan
// 

import 'package:flutter_test/flutter_test.dart';
import 'package:nearbite_app/models/restaurant_model.dart';
import 'package:nearbite_app/models/menu_item_model.dart';

void main() {
  // 
  // GROUP 1: FORM VALIDATION TESTS
  // 
  
  group('Form Validation Tests', () {
    // 
    // TEST 1: Validasi Nama Restoran
    // 
    test('Nama restoran validasi', () {
      String? validateName(String? value) {
        if (value == null || value.isEmpty) {
          return 'Nama restoran harus diisi';
        }
        if (value.length < 3) {
          return 'Nama minimal 3 karakter';
        }
        return null;
      }

      expect(validateName(''), 'Nama restoran harus diisi');
      expect(validateName(null), 'Nama restoran harus diisi');
      expect(validateName('Ab'), 'Nama minimal 3 karakter');
      expect(validateName('Warung Makan'), null);
      expect(validateName('Resto'), null);
    });

    // 
    // TEST 2: Validasi Koordinat
    // 
    test('Koordinat validasi', () {
      String? validateLatitude(String? value) {
        if (value == null || value.isEmpty) {
          return 'Latitude harus diisi';
        }
        try {
          final lat = double.parse(value);
          if (lat < -90 || lat > 90) {
            return 'Latitude antara -90 s.d 90';
          }
        } catch (_) {
          return 'Format latitude tidak valid';
        }
        return null;
      }

      String? validateLongitude(String? value) {
        if (value == null || value.isEmpty) {
          return 'Longitude harus diisi';
        }
        try {
          final lon = double.parse(value);
          if (lon < -180 || lon > 180) {
            return 'Longitude antara -180 s.d 180';
          }
        } catch (_) {
          return 'Format longitude tidak valid';
        }
        return null;
      }

      expect(validateLatitude(''), 'Latitude harus diisi');
      expect(validateLatitude(null), 'Latitude harus diisi');
      expect(validateLatitude('-100'), 'Latitude antara -90 s.d 90');
      expect(validateLatitude('100'), 'Latitude antara -90 s.d 90');
      expect(validateLatitude('abc'), 'Format latitude tidak valid');
      expect(validateLatitude('-6.979026'), null);
      expect(validateLatitude('0'), null);

      expect(validateLongitude(''), 'Longitude harus diisi');
      expect(validateLongitude(null), 'Longitude harus diisi');
      expect(validateLongitude('-200'), 'Longitude antara -180 s.d 180');
      expect(validateLongitude('200'), 'Longitude antara -180 s.d 180');
      expect(validateLongitude('abc'), 'Format longitude tidak valid');
      expect(validateLongitude('110.411453'), null);
      expect(validateLongitude('0'), null);
    });

    // 
    // TEST 3: Validasi Harga Menu
    // 
    test('Harga menu validasi', () {
      String? validatePrice(String? value) {
        if (value == null || value.isEmpty) {
          return 'Harga harus diisi';
        }
        try {
          final price = int.parse(value);
          if (price < 0) {
            return 'Harga tidak boleh negatif';
          }
        } catch (_) {
          return 'Harga harus berupa angka';
        }
        return null;
      }

      expect(validatePrice(''), 'Harga harus diisi');
      expect(validatePrice(null), 'Harga harus diisi');
      expect(validatePrice('abc'), 'Harga harus berupa angka');
      expect(validatePrice('-1000'), 'Harga tidak boleh negatif');
      expect(validatePrice('25000'), null);
      expect(validatePrice('0'), null);
    });

    // 
    // TEST 4: Validasi Nama Menu
    // 
    test('Nama menu validasi', () {
      String? validateMenuName(String? value) {
        if (value == null || value.isEmpty) {
          return 'Nama menu harus diisi';
        }
        return null;
      }

      expect(validateMenuName(''), 'Nama menu harus diisi');
      expect(validateMenuName(null), 'Nama menu harus diisi');
      expect(validateMenuName('Nasi Goreng'), null);
    });
  });

  // 
  // GROUP 2: RESTAURANT MODEL TESTS
  // 
  
  group('Restaurant Model Tests', () {
    final DateTime now = DateTime.now();

    // 
    // TEST 5: RestaurantModel fromJson
    // 
    test('RestaurantModel fromJson', () {
      final json = {
        'id': '123',
        'owner_id': 'owner-456',
        'name': 'Resto Test',
        'description': 'Deskripsi test',
        'address': 'Jl. Test No.1',
        'latitude': -6.979026,
        'longitude': 110.411453,
        'photo_url': null,
        'open_hours': '10:00-22:00',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final restaurant = RestaurantModel.fromJson(json);
      expect(restaurant.id, '123');
      expect(restaurant.ownerId, 'owner-456');
      expect(restaurant.name, 'Resto Test');
      expect(restaurant.latitude, -6.979026);
      expect(restaurant.longitude, 110.411453);
    });

    // 
    // TEST 6: RestaurantModel toJson
    // 
    test('RestaurantModel toJson', () {
      final restaurant = RestaurantModel(
        id: '1',
        ownerId: 'owner1',
        name: 'Resto Test',
        description: 'Deskripsi',
        address: 'Jl. Test',
        latitude: -6.0,
        longitude: 110.0,
        openHours: '08:00-17:00',
        createdAt: now,
        updatedAt: now,
      );

      final json = restaurant.toJson();
      expect(json['owner_id'], 'owner1');
      expect(json['name'], 'Resto Test');
      expect(json['latitude'], -6.0);
      expect(json['longitude'], 110.0);
      expect(json['open_hours'], '08:00-17:00');
    });

    // 
    // TEST 7: RestaurantModel copyWith
    // 
    test('RestaurantModel copyWith', () {
      final restaurant = RestaurantModel(
        id: '1',
        ownerId: 'owner1',
        name: 'Resto Lama',
        description: 'Deskripsi lama',
        address: 'Jl. Lama',
        latitude: -6.0,
        longitude: 110.0,
        openHours: '08:00-17:00',
        createdAt: now,
        updatedAt: now,
      );

      final updated = restaurant.copyWith(
        name: 'Resto Baru',
        description: 'Deskripsi baru',
        latitude: -7.0,
      );

      expect(updated.id, '1');
      expect(updated.name, 'Resto Baru');
      expect(updated.description, 'Deskripsi baru');
      expect(updated.latitude, -7.0);
      expect(updated.longitude, 110.0);
      expect(updated.openHours, '08:00-17:00');
    });
  });

  // 
  // GROUP 3: MENU MODEL TESTS
  // 
  
  group('Menu Model Tests', () {
    final DateTime now = DateTime.now();

    // 
    // TEST 8: MenuItemModel fromJson
    // 
    test('MenuItemModel fromJson', () {
      final json = {
        'id': 'menu-1',
        'restaurant_id': 'resto-1',
        'name': 'Nasi Goreng',
        'description': 'Nasi goreng spesial',
        'price': 25000,
        'photo_url': null,
        'is_available': true,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final menu = MenuItemModel.fromJson(json);
      expect(menu.id, 'menu-1');
      expect(menu.restaurantId, 'resto-1');
      expect(menu.name, 'Nasi Goreng');
      expect(menu.price, 25000);
      expect(menu.isAvailable, true);
    });

    // 
    // TEST 9: MenuItemModel toJson
    // 
    test('MenuItemModel toJson', () {
      final menu = MenuItemModel(
        id: '1',
        restaurantId: 'r1',
        name: 'Menu Test',
        description: 'Deskripsi',
        price: 15000,
        isAvailable: true,
        createdAt: now,
      );

      final json = menu.toJson();
      expect(json['restaurant_id'], 'r1');
      expect(json['name'], 'Menu Test');
      expect(json['price'], 15000);
      expect(json['is_available'], true);
    });

    // 
    // TEST 10: MenuItemModel priceFormatted
    // 
    test('MenuItemModel priceFormatted - format harga ke Rupiah', () {
      // Harga 25000 → Rp25.000 (TANPA spasi)
      final menu1 = MenuItemModel(
        id: '1',
        restaurantId: 'r1',
        name: 'Menu 1',
        description: '',
        price: 25000,
        isAvailable: true,
        createdAt: now,
      );
      expect(menu1.priceFormatted, 'Rp25.000');

      // Harga 1500000 → Rp1.500.000
      final menu2 = MenuItemModel(
        id: '2',
        restaurantId: 'r1',
        name: 'Menu 2',
        description: '',
        price: 1500000,
        isAvailable: true,
        createdAt: now,
      );
      expect(menu2.priceFormatted, 'Rp1.500.000');

      // Harga 75000 → Rp75.000
      final menu3 = MenuItemModel(
        id: '3',
        restaurantId: 'r1',
        name: 'Menu 3',
        description: '',
        price: 75000,
        isAvailable: true,
        createdAt: now,
      );
      expect(menu3.priceFormatted, 'Rp75.000');

      // Harga null → fallback
      final menu4 = MenuItemModel(
        id: '4',
        restaurantId: 'r1',
        name: 'Menu 4',
        description: '',
        price: null,
        isAvailable: true,
        createdAt: now,
      );
      expect(menu4.priceFormatted, 'Harga tersedia di restoran');
    });

    // 
    // TEST 11: MenuItemModel copyWith
    // 
    test('MenuItemModel copyWith', () {
      final menu = MenuItemModel(
        id: '1',
        restaurantId: 'r1',
        name: 'Menu Lama',
        description: 'Deskripsi lama',
        price: 10000,
        isAvailable: true,
        createdAt: now,
      );

      final updated = menu.copyWith(
        name: 'Menu Baru',
        price: 20000,
        isAvailable: false,
      );

      expect(updated.id, '1');
      expect(updated.name, 'Menu Baru');
      expect(updated.price, 20000);
      expect(updated.isAvailable, false);
    });
  });

  // 
  // GROUP 4: FILTER & SORT TESTS
  // 
  
  group('Filter & Sort Tests', () {
    final DateTime now = DateTime.now();

    // 
    // TEST 12: Filter menu berdasarkan ketersediaan
    // 
    test('Filter menu berdasarkan ketersediaan', () {
      final menus = [
        MenuItemModel(
          id: '1',
          restaurantId: 'r1',
          name: 'Menu 1',
          description: '',
          price: 10000,
          isAvailable: true,
          createdAt: now,
        ),
        MenuItemModel(
          id: '2',
          restaurantId: 'r1',
          name: 'Menu 2',
          description: '',
          price: 20000,
          isAvailable: false,
          createdAt: now,
        ),
        MenuItemModel(
          id: '3',
          restaurantId: 'r1',
          name: 'Menu 3',
          description: '',
          price: 30000,
          isAvailable: true,
          createdAt: now,
        ),
      ];

      final available = menus.where((m) => m.isAvailable).toList();
      expect(available.length, 2);
      expect(available[0].name, 'Menu 1');
      expect(available[1].name, 'Menu 3');

      final unavailable = menus.where((m) => !m.isAvailable).toList();
      expect(unavailable.length, 1);
      expect(unavailable[0].name, 'Menu 2');
    });

    // 
    // TEST 13: Sort menu berdasarkan harga
    // 
    test('Sort menu berdasarkan harga (termurah ke termahal)', () {
      final menus = [
        MenuItemModel(
          id: '1',
          restaurantId: 'r1',
          name: 'Menu 1',
          description: '',
          price: 30000,
          isAvailable: true,
          createdAt: now,
        ),
        MenuItemModel(
          id: '2',
          restaurantId: 'r1',
          name: 'Menu 2',
          description: '',
          price: 10000,
          isAvailable: true,
          createdAt: now,
        ),
        MenuItemModel(
          id: '3',
          restaurantId: 'r1',
          name: 'Menu 3',
          description: '',
          price: 20000,
          isAvailable: true,
          createdAt: now,
        ),
      ];

      final sorted = List<MenuItemModel>.from(menus);
      sorted.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));

      expect(sorted[0].name, 'Menu 2');
      expect(sorted[1].name, 'Menu 3');
      expect(sorted[2].name, 'Menu 1');
    });
  });
}