// 
// UNIT 4: Model Restoran
// FILE: lib/models/restaurant_model.dart
// 
// CARA KERJA:
// 1. Merepresentasikan data restoran dari database
// 2. Field utama sesuai dengan kolom di tabel restaurants
// 3. Field distance/distanceText OPSIONAL (hanya untuk UI)
// 4. fromJson(): mengubah JSON Supabase → object Dart
// 5. toJson(): mengubah object Dart → Map untuk insert/update
// 6. copyWith(): membuat clone dengan perubahan field tertentu
// 

class RestaurantModel {
  // 
  // FIELD: Data dari database (WAJIB)
  // 
  final String id;          // UUID primary key
  final String ownerId;     // foreign key ke users.id
  final String name;        // nama restoran
  final String description; // deskripsi restoran
  final String address;     // alamat lengkap
  final double latitude;    // koordinat lintang (derajat)
  final double longitude;   // koordinat bujur (derajat)
  final String? photoUrl;   // URL foto (nullable)
  final String openHours;   // jam operasional
  final DateTime createdAt; // waktu dibuat di database
  final DateTime updatedAt; // waktu terakhir update

  // 
  // FIELD: Tambahan untuk UI (OPSIONAL)
  // 
  final double? distance;     // jarak dalam km (nullable)
  final String? distanceText; // jarak terformat (nullable)

  // 
  // KONSTRUKTOR
  // CARA KERJA:
  // 1. Semua field utama WAJIB diisi (required)
  // 2. Field opsional boleh null
  // 3. Dipanggil saat membuat object RestaurantModel
  // 
  RestaurantModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.photoUrl,
    required this.openHours,
    required this.createdAt,
    required this.updatedAt,
    this.distance,
    this.distanceText,
  });

  // 
  // FACTORY: fromJson()
  // CARA KERJA:
  // 1. Terima Map<String, dynamic> dari response Supabase
  // 2. Ambil setiap field dengan key yang sesuai
  // 3. Konversi tipe data (String → double, String → DateTime)
  // 4. Jika field null, beri default value
  // 5. Kembalikan object RestaurantModel
  // 6. Dipanggil di RestaurantService setelah menerima response
  // 
  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'].toString(),
      ownerId: json['owner_id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      photoUrl: json['photo_url'],
      openHours: json['open_hours'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // 
  // METHOD: copyWith()
  // CARA KERJA:
  // 1. Membuat clone object dengan perubahan field tertentu
  // 2. Field yang tidak disebutkan tetap pakai nilai lama
  // 3. Berguna untuk mengupdate 1-2 field tanpa membuat ulang semua
  // 4. Contoh: restaurant.copyWith(distance: 1.5)
  // 
  RestaurantModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? photoUrl,
    String? openHours,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? distance,
    String? distanceText,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photoUrl: photoUrl ?? this.photoUrl,
      openHours: openHours ?? this.openHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      distance: distance ?? this.distance,
      distanceText: distanceText ?? this.distanceText,
    );
  }

  // 
  // METHOD: toJson()
  // CARA KERJA:
  // 1. Mengubah object menjadi Map<String, dynamic>
  // 2. Hanya field yang ada di database yang dimasukkan
  // 3. distance dan distanceText TIDAK dimasukkan (hanya untuk UI)
  // 4. Dipakai untuk insert/update ke Supabase
  // 
  Map<String, dynamic> toJson() {
    return {
      'owner_id': ownerId,
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'photo_url': photoUrl,
      'open_hours': openHours,
    };
  }

  // 
  // GETTER: distanceDisplay
  // CARA KERJA:
  // 1. Jika distance dan distanceText tersedia, tampilkan distanceText
  // 2. Jika tidak, tampilkan "Lokasi tidak diketahui"
  // 3. Dipakai di UI untuk menampilkan jarak
  // 
  String get distanceDisplay {
    if (distance != null && distanceText != null) {
      return distanceText!;
    }
    return 'Lokasi tidak diketahui';
  }

  // 
  // GETTER: hasDistance
  // CARA KERJA:
  // 1. Cek apakah field distance tidak null
  // 2. Return true jika ada, false jika tidak
  // 3. Dipakai di UI untuk conditional rendering
  // 
  bool get hasDistance => distance != null;
}