// FILE: lib/services/restaurant_service.dart
// FUNGSI: Service dengan error handling menggunakan ApiError

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/restaurant_model.dart';
import '../models/api_error.dart';
import '../utils/distance_utils.dart';
import '../utils/sort_utils.dart';
import 'cache_service.dart';
import 'api_client.dart';

class RestaurantService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final CacheService _cache = CacheService();

  // 
  // HELPER: Konversi PostgrestException ke ApiError
  // 
  ApiError _handlePostgrestError(PostgrestException e) {
    int statusCode = 500;
    try {
      statusCode = int.parse(e.code ?? '');
    } catch (_) {
      statusCode = 500;
    }
    return ApiErrorMapper.fromStatusCode(statusCode, message: e.message);
  }

  // 
  // HELPER: Handle error umum
  // 
  ApiError _handleGeneralError(Object e) {
    return ApiErrorMapper.fromException(e);
  }

  // 
  // METHOD: getRestaurants()
  // 
  Future<List<RestaurantModel>> getRestaurants() async {
    try {
      final response = await _supabase
          .from('restaurants')
          .select()
          .order('name');

      return (response as List)
          .map((item) => RestaurantModel.fromJson(item))
          .toList();
    } on PostgrestException catch (e) {
      throw _handlePostgrestError(e);
    } catch (e) {
      throw _handleGeneralError(e);
    }
  }

  // 
  // METHOD: getRestaurantsWithFallback()
  // 
  Future<List<RestaurantModel>> getRestaurantsWithFallback() async {
    try {
      final restaurants = await getRestaurants();
      await _cache.saveRestaurants(restaurants);
      return restaurants;
    } on ApiError {
      final cached = await _cache.getRestaurants();
      if (cached.isNotEmpty) {
        return cached;
      }
      return _cache.getFixtureRestaurants();
    } catch (e) {
      final cached = await _cache.getRestaurants();
      if (cached.isNotEmpty) {
        return cached;
      }
      return _cache.getFixtureRestaurants();
    }
  }

  // 
  // METHOD: getNearbyRestaurants()
  // 
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
    } on ApiError {
      rethrow;
    } catch (e) {
      throw _handleGeneralError(e);
    }
  }

  // 
  // METHOD: getNearbyRestaurantsWithFallback()
  // 
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

  // 
  // METHOD: getRestaurantDetail() - DIPERBAIKI
  // CARA KERJA:
  // 1. Cek apakah ID valid (tidak kosong)
  // 2. Gunakan maybeSingle() agar tidak error jika data tidak ditemukan
  // 3. Jika response null, throw exception "Restoran tidak ditemukan"
  // 4. Pastikan menu_items selalu berupa List (jika null, jadikan [])
  // 5. Kembalikan Map<String, dynamic>
  // 6. Semua error dikonversi ke ApiError
  // 
  Future<Map<String, dynamic>> getRestaurantDetail(String restaurantId) async {
    try {
      // Step 1: Validasi ID
      if (restaurantId.isEmpty) {
        throw Exception('ID restoran tidak valid');
      }

      // Step 2: Query dengan maybeSingle
      final response = await _supabase
          .from('restaurants')
          .select('*, menu_items(*)')
          .eq('id', restaurantId)
          .maybeSingle();

      // Step 3: Cek apakah data ditemukan
      if (response == null) {
        throw Exception('Restoran tidak ditemukan');
      }

      // Step 4: Pastikan menu_items selalu List
      if (response['menu_items'] == null) {
        response['menu_items'] = [];
      }

      // Step 5: Return response
      return response;

    } on PostgrestException catch (e) {
      throw _handlePostgrestError(e);
    } catch (e) {
      throw _handleGeneralError(e);
    }
  }

  // 
  // METHOD: searchRestaurants()
  // 
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
    } on PostgrestException catch (e) {
      throw _handlePostgrestError(e);
    } catch (e) {
      throw _handleGeneralError(e);
    }
  }

  // 
  // METHOD: searchRestaurantsWithDistance()
  // 
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
    } on ApiError {
      rethrow;
    } catch (e) {
      throw _handleGeneralError(e);
    }
  }

  // 
  // METHOD: getOwnerRestaurants()
  // 
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
    } on PostgrestException catch (e) {
      throw _handlePostgrestError(e);
    } catch (e) {
      throw _handleGeneralError(e);
    }
  }

  // 
  // METHOD: createRestaurant()
  // 
  Future<void> createRestaurant(Map<String, dynamic> data) async {
    try {
      await _supabase.from('restaurants').insert(data);
    } on PostgrestException catch (e) {
      throw _handlePostgrestError(e);
    } catch (e) {
      throw _handleGeneralError(e);
    }
  }

  // 
  // METHOD: updateRestaurant()
  // 
  Future<void> updateRestaurant({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _supabase
          .from('restaurants')
          .update(data)
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw _handlePostgrestError(e);
    } catch (e) {
      throw _handleGeneralError(e);
    }
  }

  // 
  // METHOD: deleteRestaurant()
  // 
  Future<void> deleteRestaurant(String id) async {
    try {
      await _supabase
          .from('restaurants')
          .delete()
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw _handlePostgrestError(e);
    } catch (e) {
      throw _handleGeneralError(e);
    }
  }

  // 
  // MENU CRUD METHODS
  // 

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
    } on PostgrestException catch (e) {
      throw _handlePostgrestError(e);
    } catch (e) {
      throw _handleGeneralError(e);
    }
  }

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
    } on PostgrestException catch (e) {
      throw _handlePostgrestError(e);
    } catch (e) {
      throw _handleGeneralError(e);
    }
  }

  Future<void> deleteMenuItem(String id) async {
    try {
      await _supabase
          .from('menu_items')
          .delete()
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw _handlePostgrestError(e);
    } catch (e) {
      throw _handleGeneralError(e);
    }
  }
}