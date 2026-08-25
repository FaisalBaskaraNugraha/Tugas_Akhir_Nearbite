// ============================================================
// UNIT: Cache Service
// FILE: lib/services/cache_service.dart
// ============================================================
// CARA KERJA:
// 1. Menyimpan dan mengambil data ke SharedPreferences
// 2. Data disimpan sebagai JSON string
// 3. Dipakai sebagai fallback ketika jaringan mati
// 4. Data seed 8 resto disimpan sebagai fixture darurat
// ============================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/restaurant_model.dart';

class CacheService {
  static const String _restaurantsKey = 'cached_restaurants';
  
  final SharedPreferences? _prefs;

  CacheService({SharedPreferences? prefs}) : _prefs = prefs;

  // ============================================================
  // METHOD: _getPrefs()
  // CARA KERJA: Ambil instance SharedPreferences
  // ============================================================
  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  // ============================================================
  // METHOD: saveRestaurants()
  // CARA KERJA: Simpan daftar restoran ke cache
  // ============================================================
  Future<void> saveRestaurants(List<RestaurantModel> restaurants) async {
    try {
      final prefs = await _getPrefs();
      final jsonList = restaurants.map((r) => r.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(_restaurantsKey, jsonString);
    } catch (e) {
      // Silent fail - cache hanya fallback
    }
  }

  // ============================================================
  // METHOD: getRestaurants()
  // CARA KERJA: Ambil daftar restoran dari cache
  // ============================================================
  Future<List<RestaurantModel>> getRestaurants() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_restaurantsKey);
      
      if (jsonString == null) {
        return getFixtureRestaurants();
      }

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => RestaurantModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return getFixtureRestaurants();
    }
  }

  // ============================================================
  // METHOD: clearCache()
  // CARA KERJA: Hapus semua cache
  // ============================================================
  Future<void> clearCache() async {
    final prefs = await _getPrefs();
    await prefs.remove(_restaurantsKey);
  }

  // ============================================================
  // METHOD: getFixtureRestaurants()
  // CARA KERJA:
  // 1. Digunakan ketika cache kosong atau error
  // 2. Data seed 8 restoran dengan koordinat tersebar
  // 3. Data ini dari seed yang sudah dibuat di database
  // ============================================================
  List<RestaurantModel> getFixtureRestaurants() {
    final now = DateTime.now();
    
    return [
      RestaurantModel(
        id: 'fix-1',
        ownerId: 'owner1',
        name: 'Masa Kitchen',
        description: 'Bubur, sup, ayam',
        address: 'Jl. Imam Bonjol No.175, Semarang',
        latitude: -6.979026,
        longitude: 110.411453,
        openHours: '11:00-21:00',
        createdAt: now,
        updatedAt: now,
      ),
      RestaurantModel(
        id: 'fix-2',
        ownerId: 'owner1',
        name: 'Waroeng Steak',
        description: 'Steak berbagai pilihan',
        address: 'Jl. Imam Bonjol No.187b, Semarang',
        latitude: -6.980964,
        longitude: 110.410440,
        openHours: '11:00-22:00',
        createdAt: now,
        updatedAt: now,
      ),
      RestaurantModel(
        id: 'fix-3',
        ownerId: 'owner1',
        name: 'Wasabi Sushi & Ramen',
        description: 'Wasabi, sushi, ramen',
        address: 'Jl. Mgr Sugiyopranoto No.23, Semarang',
        latitude: -6.982296,
        longitude: 110.404482,
        openHours: '11:00-21:30',
        createdAt: now,
        updatedAt: now,
      ),
      RestaurantModel(
        id: 'fix-4',
        ownerId: 'owner2',
        name: 'Mie Gacoan',
        description: 'Mie dengan berbagai makanan sampingan',
        address: 'Jl. Imam Bonjol No.188, Semarang',
        latitude: -6.977507,
        longitude: 110.412543,
        openHours: '10:00-00:00',
        createdAt: now,
        updatedAt: now,
      ),
      RestaurantModel(
        id: 'fix-5',
        ownerId: 'owner2',
        name: 'Ayam Goreng Roodfoodie',
        description: 'Olahan ayam goreng',
        address: 'Jl. Bima Raya No.11 B, Semarang',
        latitude: -6.979644,
        longitude: 110.407360,
        openHours: '08:00-18:00',
        createdAt: now,
        updatedAt: now,
      ),
      RestaurantModel(
        id: 'fix-6',
        ownerId: 'owner2',
        name: 'Resto Padang Bungo Padi',
        description: 'Masakan Padang',
        address: 'Jl. Mgr Sugiyopranoto No.41, Semarang',
        latitude: -6.981821,
        longitude: 110.405224,
        openHours: '10:00-22:00',
        createdAt: now,
        updatedAt: now,
      ),
      RestaurantModel(
        id: 'fix-7',
        ownerId: 'owner1',
        name: 'Antarakata Tugu Muda',
        description: 'Makanan barat dan nusantara',
        address: 'Jl. HOS Cokroaminoto, Semarang',
        latitude: -6.983375,
        longitude: 110.408004,
        openHours: '08:00-23:00',
        createdAt: now,
        updatedAt: now,
      ),
      RestaurantModel(
        id: 'fix-8',
        ownerId: 'owner2',
        name: 'Kartika Grand Bistro',
        description: 'Makanan Barat',
        address: 'Jl. Mgr Sugiyopranoto No.1, Semarang',
        latitude: -6.983022,
        longitude: 110.407650,
        openHours: '10:00-22:00',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}