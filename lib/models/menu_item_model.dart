// 
// UNIT: Model Menu Item
// FILE: lib/models/menu_item_model.dart
// 
// CARA KERJA:
// 1. Definisikan semua field sesuai kolom di tabel menu_items
// 2. fromJson() - ubah JSON dari Supabase menjadi object Dart
// 3. toJson() - ubah object Dart menjadi Map untuk insert/update
// 4. priceFormatted - format harga ke Rupiah (tanpa spasi)
// 

class MenuItemModel {
  // FIELD UTAMA (dari database)
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final int? price;
  final String? photoUrl;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // KONSTRUKTOR
  MenuItemModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    this.price,
    this.photoUrl,
    required this.isAvailable,
    required this.createdAt,
    this.updatedAt,
  });

  // FACTORY: dari JSON Supabase
  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'].toString(),
      restaurantId: json['restaurant_id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'],
      photoUrl: json['photo_url'],
      isAvailable: json['is_available'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // COPYWITH
  MenuItemModel copyWith({
    String? id,
    String? restaurantId,
    String? name,
    String? description,
    int? price,
    String? photoUrl,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      photoUrl: photoUrl ?? this.photoUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // TOJSON: untuk insert/update
  Map<String, dynamic> toJson() {
    return {
      'restaurant_id': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'photo_url': photoUrl,
      'is_available': isAvailable,
    };
  }

  // 
  // GETTER: priceFormatted
  // CARA KERJA:
  // 1. Jika price null, tampilkan "Harga tersedia di restoran"
  // 2. Jika price ada, format ke Rupiah dengan pemisah ribuan
  // 3. Contoh: 25000 → "Rp25.000" (TANPA spasi)
  // 4. Dipakai di UI untuk menampilkan harga
  // 
  String get priceFormatted {
    if (price == null) return 'Harga tersedia di restoran';
    return 'Rp${price!.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  // CEK APAKAH MENU TERSEDIA
  bool get isAvailableDisplay => isAvailable;
}