// ============================================================
// UNIT: Edit Restaurant
// FILE: lib/screens/owner/edit_restaurant_screen.dart
// ============================================================
// CARA KERJA:
// 1. Form untuk mengedit restoran yang sudah ada
// 2. Field terisi otomatis dari data restoran
// 3. Update ke database via RestaurantService.updateRestaurant()
// ============================================================

import 'package:flutter/material.dart';
import '../../models/restaurant_model.dart';
import '../../services/restaurant_service.dart';

class EditRestaurantScreen extends StatefulWidget {
  final RestaurantModel restaurant;

  const EditRestaurantScreen({
    super.key,
    required this.restaurant,
  });

  @override
  State<EditRestaurantScreen> createState() => _EditRestaurantScreenState();
}

class _EditRestaurantScreenState extends State<EditRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  late final TextEditingController _openHoursController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    _nameController = TextEditingController(text: widget.restaurant.name);
    _descriptionController = TextEditingController(text: widget.restaurant.description);
    _addressController = TextEditingController(text: widget.restaurant.address);
    _openHoursController = TextEditingController(text: widget.restaurant.openHours);
    _latitudeController = TextEditingController(
      text: widget.restaurant.latitude.toString(),
    );
    _longitudeController = TextEditingController(
      text: widget.restaurant.longitude.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _openHoursController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  // ============================================================
  // UPDATE RESTAURANT
  // ============================================================
  Future<void> _updateRestaurant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = RestaurantService();
      await service.updateRestaurant(
        id: widget.restaurant.id,
        data: {
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'address': _addressController.text.trim(),
          'latitude': double.parse(_latitudeController.text.trim()),
          'longitude': double.parse(_longitudeController.text.trim()),
          'open_hours': _openHoursController.text.trim(),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restoran berhasil diupdate!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengupdate: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.restaurant.name}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Restoran
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Restoran *',
                  prefixIcon: Icon(Icons.store),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama restoran harus diisi';
                  }
                  if (value.length < 3) {
                    return 'Nama minimal 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Deskripsi
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Alamat
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Jam Buka
              TextFormField(
                controller: _openHoursController,
                decoration: const InputDecoration(
                  labelText: 'Jam Buka (contoh: 10:00-22:00)',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Koordinat
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude *',
                        prefixIcon: Icon(Icons.my_location),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Latitude harus diisi';
                        }
                        try {
                          final lat = double.parse(value);
                          if (lat < -90 || lat > 90) {
                            return 'Latitude antara -90 s.d 90';
                          }
                        } catch (_) {
                          return 'Format latitude tidak valid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude *',
                        prefixIcon: Icon(Icons.my_location),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Longitude harus diisi';
                        }
                        try {
                          final lon = double.parse(value);
                          if (lon < -180 || lon > 180) {
                            return 'Longitude antara -180 s.d 180';
                          }
                        } catch (_) {
                          return 'Format longitude tidak valid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '* Wajib diisi',
                        style: TextStyle(fontSize: 14, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Update
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _isLoading ? null : _updateRestaurant,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Update Restoran', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}