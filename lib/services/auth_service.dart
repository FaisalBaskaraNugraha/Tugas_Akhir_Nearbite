// 
// UNIT 6: Service Autentikasi
// FILE: lib/services/auth_service.dart
// 
// CARA KERJA:
// 1. Class ini mengelola autentikasi (register, login, logout)
// 2. extends ChangeNotifier agar bisa memberi tahu UI saat ada perubahan
// 3. Menggunakan Supabase Auth untuk backend
// 4. Token/sesi disimpan otomatis oleh Supabase
// 

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 
// CLASS: AuthService
// CARA KERJA:
// 1. extends ChangeNotifier: bisa memberi tahu UI saat state berubah
// 2. currentUser: getter untuk mengambil user yang sedang login
// 3. register(): daftar akun baru di Supabase Auth
// 4. login(): login dengan email dan password
// 5. logout(): logout dan hapus sesi
// 6. Dipakai di seluruh app via Provider
// 
class AuthService extends ChangeNotifier {
  // Koneksi ke Supabase
  final SupabaseClient _supabase = Supabase.instance.client;

  // 
  // GETTER: currentUser
  // CARA KERJA:
  // 1. Mengambil user yang sedang login dari Supabase Auth
  // 2. Jika tidak ada user, return null
  // 3. Dipakai di AuthWrapper untuk menentukan halaman awal
  // 
  User? get currentUser => _supabase.auth.currentUser;

  // 
  // METHOD: register()
  // CARA KERJA:
  // 1. Terima email, password, fullName dari RegisterScreen
  // 2. Kirim request ke Supabase Auth via signUp()
  // 3. Data full_name dikirim di raw_user_meta_data
  // 4. Trigger di Supabase akan otomatis buat row di public.users
  // 5. notifyListeners() memberi tahu UI bahwa ada perubahan
  // 6. Return AuthResponse (berisi user dan session)
  // 
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName}, // 👈 Dipakai trigger di Supabase
    );
    notifyListeners();
    return response;
  }

  // 
  // METHOD: login()
  // CARA KERJA:
  // 1. Terima email dan password dari LoginScreen
  // 2. Kirim request ke Supabase Auth via signInWithPassword()
  // 3. Jika berhasil, Supabase menyimpan session token
  // 4. notifyListeners() memberi tahu UI ada perubahan
  // 5. Return AuthResponse (berisi user dan session)
  // 
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    notifyListeners();
    return response;
  }

  // 
  // METHOD: logout()
  // CARA KERJA:
  // 1. Panggil signOut() di Supabase Auth
  // 2. Menghapus session token yang tersimpan
  // 3. notifyListeners() memberi tahu UI ada perubahan
  // 4. UI akan redirect ke LoginScreen (lewat AuthWrapper)
  // 
  Future<void> logout() async {
    await _supabase.auth.signOut();
    notifyListeners();
  }
}