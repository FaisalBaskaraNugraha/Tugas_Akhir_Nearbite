// 
// UNIT: Manage Menu Screen
// FILE: lib/screens/owner/manage_menu_screen.dart
// 
// CARA KERJA:
// 1. Menampilkan daftar menu dari restoran tertentu
// 2. Tombol tambah menu baru (FAB)
// 3. Setiap menu: Edit dan Hapus
// 4. Navigasi ke AddMenuScreen dan EditMenuScreen
// 5. State: loading, error, empty, success
// 

import 'package:flutter/material.dart';
import '../../models/menu_item_model.dart';
import '../../services/restaurant_service.dart';
import 'add_menu_screen.dart';
import 'edit_menu_screen.dart';

class ManageMenuScreen extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;

  const ManageMenuScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  State<ManageMenuScreen> createState() => _ManageMenuScreenState();
}

class _ManageMenuScreenState extends State<ManageMenuScreen> {
  List<MenuItemModel> _menuItems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  // 
  // LOAD MENU ITEMS
  // 
  Future<void> _loadMenuItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = RestaurantService();
      final data = await service.getRestaurantDetail(widget.restaurantId);
      
      final menuData = data['menu_items'] as List? ?? [];
      _menuItems = menuData
          .map((item) => MenuItemModel.fromJson(item))
          .toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat menu: $e';
        _isLoading = false;
      });
    }
  }

  // 
  // DELETE MENU ITEM
  // 
  Future<void> _deleteMenuItem(MenuItemModel menu) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Menu'),
        content: Text('Yakin ingin menghapus "${menu.name}"?'),
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
      await service.deleteMenuItem(menu.id);
      _loadMenuItems();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menu berhasil dihapus'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu ${widget.restaurantName}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMenuItems,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMenuScreen(
                restaurantId: widget.restaurantId,
              ),
            ),
          ).then((_) => _loadMenuItems());
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  // 
  // BUILD BODY
  // 
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
              'Gagal memuat menu',
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
              onPressed: _loadMenuItems,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    if (_menuItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fastfood, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada menu',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan menu pertama Anda',
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
                    builder: (context) => AddMenuScreen(
                      restaurantId: widget.restaurantId,
                    ),
                  ),
                ).then((_) => _loadMenuItems());
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Menu'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMenuItems,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _menuItems.length,
        itemBuilder: (context, index) {
          final menu = _menuItems[index];
          return _buildMenuItemCard(menu);
        },
      ),
    );
  }

  // 
  // MENU ITEM CARD
  // 
  Widget _buildMenuItemCard(MenuItemModel menu) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: menu.photoUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    menu.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.fastfood, color: Colors.grey[400]);
                    },
                  ),
                )
              : Icon(Icons.fastfood, color: Colors.grey[400]),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                menu.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
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
            if (menu.description.isNotEmpty)
              Text(
                menu.description,
                style: TextStyle(color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Text(
              menu.priceFormatted,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditMenuScreen(
                      menu: menu,
                    ),
                  ),
                ).then((_) => _loadMenuItems());
              },
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteMenuItem(menu),
              tooltip: 'Hapus',
            ),
          ],
        ),
        isThreeLine: menu.description.isNotEmpty,
      ),
    );
  }
}