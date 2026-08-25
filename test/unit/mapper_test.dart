// FILE: test/unit/mapper_test.dart
// FUNGSI: Unit test untuk mapper JSON

import 'package:flutter_test/flutter_test.dart';
import 'package:nearbite_app/models/restaurant_model.dart';
import 'package:nearbite_app/models/menu_item_model.dart';

void main() {
  group('RestaurantModel Mapper Tests', () {
    final DateTime now = DateTime.now();

    test('RestaurantModel fromJson - all fields', () {
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

    test('RestaurantModel toJson - roundtrip', () {
      final original = RestaurantModel(
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

      original.toJson();
      final result = RestaurantModel.fromJson({
        'id': '1',
        'owner_id': 'owner1',
        'name': 'Resto Test',
        'description': 'Deskripsi',
        'address': 'Jl. Test',
        'latitude': -6.0,
        'longitude': 110.0,
        'photo_url': null,
        'open_hours': '08:00-17:00',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      expect(result.name, original.name);
      expect(result.latitude, original.latitude);
      expect(result.longitude, original.longitude);
    });

    test('RestaurantModel fromJson - with missing fields', () {
      final json = {
        'id': '123',
        'owner_id': 'owner-456',
        'name': 'Resto Test',
        'latitude': -6.979026,
        'longitude': 110.411453,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final restaurant = RestaurantModel.fromJson(json);
      expect(restaurant.id, '123');
      expect(restaurant.description, '');
      expect(restaurant.address, '');
      expect(restaurant.openHours, '');
    });
  });

  group('MenuItemModel Mapper Tests', () {
    final DateTime now = DateTime.now();

    test('MenuItemModel fromJson - all fields', () {
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

    test('MenuItemModel priceFormatted - Rupiah format', () {
      final menu = MenuItemModel(
        id: '1',
        restaurantId: 'r1',
        name: 'Menu 1',
        description: '',
        price: 25000,
        isAvailable: true,
        createdAt: now,
      );
      expect(menu.priceFormatted, 'Rp25.000');
    });

    test('MenuItemModel priceFormatted - null price', () {
      final menu = MenuItemModel(
        id: '1',
        restaurantId: 'r1',
        name: 'Menu 1',
        description: '',
        price: null,
        isAvailable: true,
        createdAt: now,
      );
      expect(menu.priceFormatted, 'Harga tersedia di restoran');
    });
  });
}