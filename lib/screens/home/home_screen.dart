// FILE: lib/screens/home/home_screen.dart
// FUNGSI: Halaman utama dengan GPS + fallback
// CARA KERJA:
// 1. Ambil lokasi pengguna saat pertama kali dibuka
// 2. Jika berhasil -> urutkan restoran berdasarkan jarak
// 3. Jika ditolak -> tampilkan daftar tanpa urutan jarak + pesan
// 4. Jika GPS mati -> tampilkan pesan + daftar tanpa urutan
// 5. Tidak pernah crash

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant_model.dart';
import '../../models/location_result.dart';
import '../../services/auth_service.dart';
import '../../services/restaurant_service.dart';
import '../../services/location_service.dart';
import 'restaurant_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<RestaurantModel> _restaurants = [];
  List<RestaurantModel> _filteredRestaurants = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  bool _isOffline = false;

  double? _userLat;
  double? _userLon;
  bool _hasLocation = false;
  String? _locationMessage;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await _getUserLocation();
    await _loadRestaurants();
  }

  Future<void> _getUserLocation() async {
    final result = await _locationService.getCurrentLocation();

    switch (result) {
      case LocationSuccess(position: final position):
        _userLat = position.latitude;
        _userLon = position.longitude;
        _hasLocation = true;
        _locationMessage = null;
        break;

      case LocationDenied(message: final message):
        _hasLocation = false;
        _locationMessage = message;
        break;

      case LocationPermanentlyDenied(message: final message):
        _hasLocation = false;
        _locationMessage = message;
        break;

      case LocationUnavailable(message: final message):
        _hasLocation = false;
        _locationMessage = message;
        break;
    }
  }

  Future<void> _loadRestaurants() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _searchQuery = '';
      _searchController.clear();
    });

    try {
      final service = RestaurantService();
      List<RestaurantModel> restaurants;

      if (_hasLocation && _userLat != null && _userLon != null) {
        restaurants = await service.getNearbyRestaurantsWithFallback(
          userLat: _userLat!,
          userLon: _userLon!,
        );
      } else {
        restaurants = await service.getRestaurantsWithFallback();
        _isOffline = true;
      }

      setState(() {
        _restaurants = restaurants;
        _filteredRestaurants = restaurants;
        _isLoading = false;
        _hasLocation = _hasLocation;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchRestaurants(String query) async {
    setState(() {
      _searchQuery = query;
      _error = null;
    });

    if (query.trim().isEmpty) {
      setState(() {
        _filteredRestaurants = _restaurants;
      });
      return;
    }

    try {
      final service = RestaurantService();
      
      List<RestaurantModel> results;
      if (_hasLocation && _userLat != null && _userLon != null) {
        results = await service.searchRestaurantsWithDistance(
          query: query,
          userLat: _userLat!,
          userLon: _userLon!,
        );
      } else {
        results = await service.searchRestaurants(query);
      }

      setState(() {
        _filteredRestaurants = results;
        _isOffline = false;
        if (results.isEmpty) {
          _error = 'Tidak ada hasil untuk "$query"';
        } else {
          _error = null;
        }
      });
    } catch (e) {
      final filtered = _restaurants.where((r) {
        return r.name.toLowerCase().contains(query.toLowerCase()) ||
            r.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
      
      setState(() {
        _filteredRestaurants = filtered;
        _isOffline = true;
        if (filtered.isEmpty) {
          _error = 'Tidak ada hasil untuk "$query" (offline)';
        } else {
          _error = 'Menampilkan ${filtered.length} hasil (offline)';
        }
      });
    }
  }

  Future<void> _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    if (mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  void _navigateToOwner() {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.currentUser != null) {
      Navigator.pushNamed(context, '/owner');
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NearBite'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isOffline || !_hasLocation)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.wifi_off, color: Colors.orange),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRestaurants,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.restaurant),
            onPressed: _navigateToOwner,
            tooltip: 'Kelola Restoran',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildSearchBar(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: _isOffline ? 'Cari offline...' : 'Cari resto atau menu...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _searchRestaurants('');
                    _searchFocusNode.unfocus();
                  },
                )
              : null,
          filled: true,
          fillColor: _isOffline ? Colors.grey[100] : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: _searchRestaurants,
        onSubmitted: (value) {
          _searchFocusNode.unfocus();
          _searchRestaurants(value);
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasLocation && _locationMessage != null) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.location_off, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _locationMessage!,
                    style: TextStyle(color: Colors.orange[700], fontSize: 13),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _locationService.openAppSettings();
                  },
                  child: Text(
                    'Setel',
                    style: TextStyle(color: Colors.orange[700]),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildRestaurantList(),
          ),
        ],
      );
    }

    if (_error != null && _restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isOffline ? Icons.wifi_off : Icons.error_outline,
              size: 64,
              color: _isOffline ? Colors.orange : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _isOffline ? 'Mode Offline' : 'Gagal memuat',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadRestaurants,
              child: Text(_isOffline ? 'Coba Online' : 'Coba lagi'),
            ),
          ],
        ),
      );
    }

    if (_filteredRestaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.restaurant,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Tidak ada hasil untuk "$_searchQuery"'
                  : 'Belum ada restoran',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Coba kata kunci lain'
                  : 'Tambahkan restoran pertama Anda',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return _buildRestaurantList();
  }

  Widget _buildRestaurantList() {
    return RefreshIndicator(
      onRefresh: _loadRestaurants,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredRestaurants.length,
        itemBuilder: (context, index) {
          final restaurant = _filteredRestaurants[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.restaurant, size: 40),
              title: Text(
                restaurant.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _hasLocation && restaurant.distanceText != null
                            ? restaurant.distanceText!
                            : 'Lokasi tidak diketahui',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          restaurant.openHours,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_searchQuery.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _isOffline
                            ? 'Hasil offline untuk "$_searchQuery"'
                            : 'Hasil untuk "$_searchQuery"',
                        style: TextStyle(
                          fontSize: 11,
                          color: _isOffline
                              ? Colors.orange[600]
                              : Theme.of(context).colorScheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  if (_isOffline && _searchQuery.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Mode offline',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange[600],
                        ),
                      ),
                    ),
                  if (!_hasLocation && _locationMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _locationMessage!.replaceFirst('.', ''),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange[600],
                        ),
                      ),
                    ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantDetailScreen(
                      restaurantId: restaurant.id,
                      userLat: _hasLocation ? _userLat : null,
                      userLon: _hasLocation ? _userLon : null,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}