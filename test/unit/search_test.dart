// FILE: test/unit/search_test.dart
// FUNGSI: Unit test untuk search resto/menu

import 'package:flutter_test/flutter_test.dart';
import 'package:nearbite_app/models/restaurant_model.dart';
import 'package:nearbite_app/models/menu_item_model.dart';

void main() {
  group('Search Logic Tests', () {
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

    List<RestaurantModel> searchRestaurants(
      List<RestaurantModel> restaurants,
      List<MenuItemModel> menuItems,
      String query,
    ) {
      if (query.trim().isEmpty) return restaurants;

      final lowerQuery = query.toLowerCase().trim();

      return restaurants.where((restaurant) {
        if (restaurant.name.toLowerCase().contains(lowerQuery)) {
          return true;
        }

        final hasMatchingMenu = menuItems.any((menu) =>
            menu.restaurantId == restaurant.id &&
            menu.name.toLowerCase().contains(lowerQuery));

        return hasMatchingMenu;
      }).toList();
    }

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

    test('Search by menu name - case insensitive', () {
      final results = searchRestaurants(restaurants, menuItems, 'bubur');
      expect(results.length, 1);
      expect(results[0].name, 'Masa Kitchen');

      final results2 = searchRestaurants(restaurants, menuItems, 'salmon');
      expect(results2.length, 1);
      expect(results2[0].name, 'Wasabi Sushi');
    });

    test('Search with partial query', () {
      final results = searchRestaurants(restaurants, menuItems, 'wa');
      expect(results.length, 2);
      expect(results.any((r) => r.name == 'Waroeng Steak'), true);
      expect(results.any((r) => r.name == 'Wasabi Sushi'), true);
    });

    test('Empty query returns all restaurants', () {
      final results = searchRestaurants(restaurants, menuItems, '');
      expect(results.length, 3);
    });

    test('Query with no match returns empty list', () {
      final results = searchRestaurants(restaurants, menuItems, 'xyz123');
      expect(results.length, 0);
    });
  });
}