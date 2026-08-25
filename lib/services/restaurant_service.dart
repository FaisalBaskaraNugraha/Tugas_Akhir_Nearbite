// ============================================================
// UNIT: Service Restoran + Cache Fallback + CRUD Menu
// FILE: lib/services/restaurant_service.dart
// ============================================================
// CARA KERJA:
// 1. Class ini mengelola semua operasi data restoran dan menu
// 2. Jembatan antara UI dan Supabase database
// 3. RESTAURANT: get, getNearby, search, getOwner, create, update, delete
// 4. MENU: create, update, delete
// 5. Cache fallback untuk offline mode
// ============================================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/restaurant_model.dart';
import '../utils/distance_utils.dart';
import '../utils/sort_utils.dart';
import 'cache_service.dart';

class RestaurantService {
  // Koneksi ke Supabase
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Cache service untuk fallback offline
  final CacheService _cache = CacheService();

  // ============================================================
  // RESTAURANT METHODS
  // ============================================================

  // GET ALL RESTAURANTS
  Future<List<RestaurantModel>> getRestaurants() async {
    try {
      final response = await _supabase
          .from('restaurants')
          .select()
          .order('name');

      return (response as List)
          .map((item) => RestaurantModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to load restaurants: $e');
    }
  }

  // GET RESTAURANTS WITH FALLBACK
  Future<List<RestaurantModel>> getRestaurantsWithFallback() async {
    try {
      final restaurants = await getRestaurants();
      await _cache.saveRestaurants(restaurants);
      return restaurants;
    } catch (e) {
      final cached = await _cache.getRestaurants();
      if (cached.isNotEmpty) {
        return cached;
      }
      return _cache.getFixtureRestaurants();
    }
  }

  // GET NEARBY RESTAURANTS
  Future<List<RestaurantModel>> getNearbyRestaurants({
    required double userLat,
    required double userLon,
  }) async {
    try {
      final restaurants = await getRestaurants();
      final sorted = sortRestaurantsByDistance(
        restaurants,
        userLat,
        userLon,
      );

      return sorted.map((restaurant) {
        final distance = calculateDistance(
          userLat,
          userLon,
          restaurant.latitude,
          restaurant.longitude,
        );
        return restaurant.copyWith(
          distance: distance,
          distanceText: formatDistance(distance),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load nearby restaurants: $e');
    }
  }

  // GET NEARBY RESTAURANTS WITH FALLBACK
  Future<List<RestaurantModel>> getNearbyRestaurantsWithFallback({
    required double userLat,
    required double userLon,
  }) async {
    try {
      final restaurants = await getRestaurantsWithFallback();
      final sorted = sortRestaurantsByDistance(
        restaurants,
        userLat,
        userLon,
      );

      return sorted.map((restaurant) {
        final distance = calculateDistance(
          userLat,
          userLon,
          restaurant.latitude,
          restaurant.longitude,
        );
        return restaurant.copyWith(
          distance: distance,
          distanceText: formatDistance(distance),
        );
      }).toList();
    } catch (e) {
      final fixture = _cache.getFixtureRestaurants();
      return fixture.map((restaurant) {
        final distance = calculateDistance(
          userLat,
          userLon,
          restaurant.latitude,
          restaurant.longitude,
        );
        return restaurant.copyWith(
          distance: distance,
          distanceText: formatDistance(distance),
        );
      }).toList();
    }
  }

  // GET RESTAURANT DETAIL + MENU
  Future<Map<String, dynamic>> getRestaurantDetail(String restaurantId) async {
    try {
      final response = await _supabase
          .from('restaurants')
          .select('*, menu_items(*)')
          .eq('id', restaurantId)
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to load restaurant detail: $e');
    }
  }

  // SEARCH RESTAURANTS
  Future<List<RestaurantModel>> searchRestaurants(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getRestaurants();
      }

      final response = await _supabase
          .rpc('search_restaurants', params: {'search_query': query.trim()});

      return (response as List)
          .map((item) => RestaurantModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to search restaurants: $e');
    }
  }

  // SEARCH RESTAURANTS WITH DISTANCE
  Future<List<RestaurantModel>> searchRestaurantsWithDistance({
    required String query,
    required double userLat,
    required double userLon,
  }) async {
    try {
      final restaurants = await searchRestaurants(query);

      return restaurants.map((restaurant) {
        final distance = calculateDistance(
          userLat,
          userLon,
          restaurant.latitude,
          restaurant.longitude,
        );
        return restaurant.copyWith(
          distance: distance,
          distanceText: formatDistance(distance),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to search restaurants with distance: $e');
    }
  }

  // GET OWNER RESTAURANTS
  Future<List<RestaurantModel>> getOwnerRestaurants(String ownerId) async {
    try {
      final response = await _supabase
          .from('restaurants')
          .select()
          .eq('owner_id', ownerId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => RestaurantModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to load owner restaurants: $e');
    }
  }

  // CREATE RESTAURANT
  Future<void> createRestaurant(Map<String, dynamic> data) async {
    try {
      await _supabase.from('restaurants').insert(data);
    } catch (e) {
      throw Exception('Failed to create restaurant: $e');
    }
  }

  // UPDATE RESTAURANT
  Future<void> updateRestaurant({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _supabase
          .from('restaurants')
          .update(data)
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update restaurant: $e');
    }
  }

  // DELETE RESTAURANT
  Future<void> deleteRestaurant(String id) async {
    try {
      await _supabase
          .from('restaurants')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete restaurant: $e');
    }
  }

  // ============================================================
  // MENU ITEM METHODS (CRUD)
  // ============================================================

  // ============================================================
  // METHOD: createMenuItem()
  // CARA KERJA:
  // 1. Insert data ke tabel menu_items
  // 2. Field: restaurant_id, name, description, price, is_available
  // 3. is_available default true
  // 4. Jika berhasil, tidak ada return value
  // 5. Jika gagal, lempar exception
  // 6. Dipanggil di AddMenuScreen
  // ============================================================
  Future<void> createMenuItem({
    required String restaurantId,
    required String name,
    required String description,
    required int price,
  }) async {
    try {
      await _supabase.from('menu_items').insert({
        'restaurant_id': restaurantId,
        'name': name,
        'description': description,
        'price': price,
        'is_available': true,
      });
    } catch (e) {
      throw Exception('Failed to create menu item: $e');
    }
  }

  // ============================================================
  // METHOD: updateMenuItem()
  // CARA KERJA:
  // 1. Update data di tabel menu_items berdasarkan id
  // 2. Field: name, description, price, is_available
  // 3. Jika berhasil, tidak ada return value
  // 4. Jika gagal, lempar exception
  // 5. Dipanggil di EditMenuScreen
  // ============================================================
  Future<void> updateMenuItem({
    required String id,
    required String name,
    required String description,
    required int price,
    required bool isAvailable,
  }) async {
    try {
      await _supabase
          .from('menu_items')
          .update({
            'name': name,
            'description': description,
            'price': price,
            'is_available': isAvailable,
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update menu item: $e');
    }
  }

  // ============================================================
  // METHOD: deleteMenuItem()
  // CARA KERJA:
  // 1. Delete data dari tabel menu_items berdasarkan id
  // 2. Jika berhasil, tidak ada return value
  // 3. Jika gagal, lempar exception
  // 4. Dipanggil di ManageMenuScreen
  // ============================================================
  Future<void> deleteMenuItem(String id) async {
    try {
      await _supabase
          .from('menu_items')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete menu item: $e');
    }
  }
}