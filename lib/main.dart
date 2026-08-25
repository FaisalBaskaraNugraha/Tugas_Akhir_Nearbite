// ============================================================
// FILE: lib/main.dart
// FUNGSI: Entry point aplikasi
// ============================================================
// CARA KERJA:
// 1. Load .env file terlebih dahulu
// 2. Inisialisasi Supabase
// 3. Jalankan aplikasi dengan HomeScreen sebagai halaman utama
// 4. HomeScreen TANPA LOGIN (mode pencari)
// 5. Login/Register hanya untuk akses owner
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'config/supabase_config.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/owner/owner_dashboard.dart';
import 'services/auth_service.dart';

// ============================================================
// main()
// CARA KERJA:
// 1. WidgetsFlutterBinding.ensureInitialized() - pastikan Flutter siap
// 2. dotenv.load() - baca file .env
// 3. SupabaseConfig.initialize() - koneksi ke Supabase
// 4. runApp() - jalankan aplikasi
// ============================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env file
  await dotenv.load(fileName: ".env");
  
  // Inisialisasi Supabase
  await SupabaseConfig.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthService>(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'NearBite',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
          ),
          useMaterial3: true,
        ),
        // ✅ Home langsung ke HomeScreen (TANPA LOGIN)
        home: const HomeScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/owner': (context) => const OwnerDashboard(),
        },
      ),
    );
  }
}