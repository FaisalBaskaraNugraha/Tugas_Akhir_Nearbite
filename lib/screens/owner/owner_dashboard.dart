// ============================================================
// UNIT: Owner Dashboard
// FILE: lib/screens/owner/owner_dashboard.dart
// ============================================================
// CARA KERJA:
// 1. Menampilkan daftar restoran milik owner yang login
// 2. Tombol tambah resto baru (FAB)
// 3. Setiap card resto: Edit, Menu, Hapus
// 4. Navigasi ke AddRestaurantScreen, EditRestaurantScreen, ManageMenuScreen
// 5. State: loading, error, empty, success
// 6. Logout: hapus sesi dan kembali ke HomeScreen (mode pencari)
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/restaurant_service.dart';
import '../../models/restaurant_model.dart';
import 'add_restaurant_screen.dart';
import 'edit_restaurant_screen.dart';
import 'manage_menu_screen.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  List<RestaurantModel> _restaurants = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  // ============================================================
  // LOAD RESTAURANTS
  // CARA KERJA:
  // 1. Ambil user ID dari AuthService
  // 2. Panggil RestaurantService.getOwnerRestaurants(userId)
  // 3. Jika berhasil, simpan ke _restaurants
  // 4. Jika gagal, tampilkan error
  // ============================================================
  Future<void> _loadRestaurants() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.id;

      if (userId == null) {
        setState(() {
          _error = 'Silakan login terlebih dahulu';
          _isLoading = false;
        });
        return;
      }

      final service = RestaurantService();
      final restaurants = await service.getOwnerRestaurants(userId);

      setState(() {
        _restaurants = restaurants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat restoran: $e';
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // DELETE RESTAURANT
  // CARA KERJA:
  // 1. Tampilkan dialog konfirmasi
  // 2. Jika user konfirmasi, panggil deleteRestaurant()
  // 3. Reload data setelah berhasil
  // ============================================================
  Future<void> _deleteRestaurant(RestaurantModel restaurant) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Restoran'),
        content: Text('Yakin ingin menghapus "${restaurant.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final service = RestaurantService();
      await service.deleteRestaurant(restaurant.id);
      _loadRestaurants();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restoran berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ============================================================
  // LOGOUT
  // CARA KERJA:
  // 1. Panggil AuthService.logout() → hapus sesi
  // 2. Navigasi ke HomeScreen (mode pencari)
  // 3. BUKAN ke LoginScreen (sesuai requirement)
  // ============================================================
  Future<void> _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    if (mounted) {
      // Kembali ke HomeScreen (mode pencari)
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  // ============================================================
  // OPTIONS MENU
  // CARA KERJA:
  // 1. Tampilkan bottom sheet dengan 3 opsi
  // 2. Edit: navigasi ke EditRestaurantScreen
  // 3. Menu: navigasi ke ManageMenuScreen
  // 4. Hapus: panggil _deleteRestaurant()
  // ============================================================
  void _showOptionsMenu(RestaurantModel restaurant) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Restoran'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditRestaurantScreen(
                      restaurant: restaurant,
                    ),
                  ),
                ).then((_) => _loadRestaurants());
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Kelola Menu'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageMenuScreen(
                      restaurantId: restaurant.id,
                      restaurantName: restaurant.name,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Hapus Restoran',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteRestaurant(restaurant);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Restoran'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          // Tombol Refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRestaurants,
            tooltip: 'Refresh',
          ),
          // ============================================================
          // TOMBOL LOGOUT
          // CARA KERJA:
          // 1. Panggil _logout()
          // 2. Hapus sesi dan kembali ke HomeScreen
          // 3. Sesuai requirement: logout → mode pencari
          // ============================================================
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddRestaurantScreen(),
            ),
          ).then((_) => _loadRestaurants());
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ============================================================
  // BUILD BODY
  // CARA KERJA:
  // 1. Jika loading, tampilkan CircularProgressIndicator
  // 2. Jika error, tampilkan pesan error + tombol retry
  // 3. Jika empty, tampilkan pesan tidak ada data + tombol tambah
  // 4. Jika success, tampilkan ListView restoran
  // ============================================================
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat restoran',
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
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    if (_restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada restoran',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan restoran pertama Anda',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddRestaurantScreen(),
                  ),
                ).then((_) => _loadRestaurants());
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Restoran'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRestaurants,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = _restaurants[index];
          return _buildRestaurantCard(restaurant);
        },
      ),
    );
  }

  // ============================================================
  // RESTAURANT CARD
  // CARA KERJA:
  // 1. Tampilkan info restoran: nama, deskripsi, alamat, jam
  // 2. 3 tombol aksi: Edit, Menu, Hapus
  // 3. Tombol Menu navigasi ke ManageMenuScreen
  // 4. Tombol Edit navigasi ke EditRestaurantScreen
  // 5. Tombol Hapus panggil _deleteRestaurant()
  // ============================================================
  Widget _buildRestaurantCard(RestaurantModel restaurant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.restaurant,
                color: Colors.grey[600],
                size: 30,
              ),
            ),
            title: Text(
              restaurant.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        restaurant.address,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      restaurant.openHours,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onPressed: () {
                _showOptionsMenu(restaurant);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditRestaurantScreen(
                            restaurant: restaurant,
                          ),
                        ),
                      ).then((_) => _loadRestaurants());
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageMenuScreen(
                            restaurantId: restaurant.id,
                            restaurantName: restaurant.name,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu_book, size: 18),
                    label: const Text('Menu'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green),
                      foregroundColor: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteRestaurant(restaurant),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Hapus'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}