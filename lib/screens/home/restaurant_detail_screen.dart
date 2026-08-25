// FILE: lib/screens/home/restaurant_detail_screen.dart
// FUNGSI: Halaman Detail Restoran + Daftar Menu
// CARA KERJA:
// 1. Terima restaurantId dari parameter
// 2. Panggil RestaurantService.getRestaurantDetail()
// 3. Tampilkan informasi restoran (nama, deskripsi, alamat, jam, jarak)
// 4. Tampilkan daftar menu dalam ListView
// 5. State: loading, success, error + retry

import 'package:flutter/material.dart';
import '../../models/restaurant_model.dart';
import '../../models/menu_item_model.dart';
import '../../services/restaurant_service.dart';
import '../../utils/distance_utils.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;
  final double? userLat;
  final double? userLon;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
    this.userLat,
    this.userLon,
  });

  @override
  State<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  // STATE
  RestaurantModel? _restaurant;
  List<MenuItemModel> _menuItems = [];
  bool _isLoading = true;
  String? _error;
  double? _distance;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  // 
  // LOAD DETAIL
  // 
  // Cara kerja:
  // 1. Set loading = true
  // 2. Panggil service.getRestaurantDetail()
  // 3. Parse response ke RestaurantModel dan List<MenuItemModel>
  // 4. Hitung jarak jika posisi user tersedia
  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = RestaurantService();
      final data = await service.getRestaurantDetail(widget.restaurantId);

      // Parse restaurant
      final restaurant = RestaurantModel.fromJson(data);
      _restaurant = restaurant;

      // Parse menu items
      final menuData = data['menu_items'] as List? ?? [];
      _menuItems = menuData
          .map((item) => MenuItemModel.fromJson(item))
          .toList();

      // Hitung jarak jika ada posisi user
      if (widget.userLat != null && widget.userLon != null) {
        _distance = calculateDistance(
          widget.userLat!,
          widget.userLon!,
          restaurant.latitude,
          restaurant.longitude,
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_restaurant?.name ?? 'Detail Restoran'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  // 
  // BUILD BODY
  // 
  Widget _buildBody() {
    // 1. STATE LOADING
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. STATE ERROR
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat detail',
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
              onPressed: _loadDetail,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    // 3. STATE EMPTY
    if (_restaurant == null) {
      return const Center(child: Text('Restoran tidak ditemukan'));
    }

    // 4. STATE SUCCESS
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPhotoSection(),
          const SizedBox(height: 16),
          _buildInfoSection(),
          const SizedBox(height: 24),
          _buildMenuSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // 
  // PHOTO SECTION
  // 
  Widget _buildPhotoSection() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: _restaurant?.photoUrl != null
          ? Image.network(
              _restaurant!.photoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholderPhoto();
              },
            )
          : _buildPlaceholderPhoto(),
    );
  }

  Widget _buildPlaceholderPhoto() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.restaurant, size: 64, color: Colors.grey[600]),
        const SizedBox(height: 8),
        Text(
          'Belum ada foto',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  // 
  // INFO SECTION
  // 
  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama
            Text(
              _restaurant!.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Deskripsi
            Text(
              _restaurant!.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),

            // Alamat
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _restaurant!.address,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Jam buka
            Row(
              children: [
                Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Buka: ${_restaurant!.openHours}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Jarak
            if (_distance != null) ...[
              Row(
                children: [
                  Icon(Icons.directions_walk, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Jarak: ${formatDistance(_distance!)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ],

            // Koordinat (debug)
            const SizedBox(height: 8),
            Text(
              '📍 ${_restaurant!.latitude}, ${_restaurant!.longitude}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // 
  // MENU SECTION
  // 
  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '📋 Menu',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '${_menuItems.length} item',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_menuItems.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Belum ada menu',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _menuItems.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final menu = _menuItems[index];
              return _buildMenuItem(menu);
            },
          ),
      ],
    );
  }

  // 
  // MENU ITEM WIDGET
  // 
  Widget _buildMenuItem(MenuItemModel menu) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: menu.photoUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                menu.photoUrl!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.fastfood, color: Colors.grey[400]),
                  );
                },
              ),
            )
          : Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.fastfood, color: Colors.grey[400]),
            ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              menu.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          if (!menu.isAvailable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Habis',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.red[700],
                ),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (menu.description.isNotEmpty) ...[
            Text(
              menu.description,
              style: TextStyle(color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
          ],
          Text(
            menu.priceFormatted,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      isThreeLine: menu.description.isNotEmpty,
    );
  }
}