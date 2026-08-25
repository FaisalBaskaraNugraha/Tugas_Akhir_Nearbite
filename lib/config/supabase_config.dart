// ============================================================
// UNIT: Konfigurasi Supabase
// FILE: lib/config/supabase_config.dart
// ============================================================
// CARA KERJA:
// 1. Class ini bertugas menyimpan dan menginisialisasi koneksi ke Supabase
// 2. Prioritas: --dart-define > .env > default
// 3. Tidak ada hardcode credentials di source code (sesuai requirement)
// 4. initialize() dipanggil di main() sebelum aplikasi berjalan
// 5. Jika credentials tidak valid, throw exception
// ============================================================

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // ============================================================
  // GETTER: supabaseUrl
  // CARA KERJA:
  // 1. Coba dari --dart-define (prioritas utama)
  // 2. Jika tidak ada, coba dari .env
  // 3. Jika tidak ada, return default (akan dianggap error)
  // 4. Tidak ada hardcode credentials
  // ============================================================
  static String get supabaseUrl {
    // Prioritas 1: --dart-define
    const fromDefine = String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: '',
    );
    if (fromDefine.isNotEmpty) return fromDefine;
    
    // Prioritas 2: .env
    final fromEnv = dotenv.env['SUPABASE_URL'];
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    
    // Prioritas 3: default (akan dianggap error di initialize)
    print('⚠️ Warning: No SUPABASE_URL found!');
    return 'https://YOUR_PROJECT.supabase.co';
  }

  // ============================================================
  // GETTER: supabaseAnonKey
  // CARA KERJA:
  // 1. Coba dari --dart-define (prioritas utama)
  // 2. Jika tidak ada, coba dari .env
  // 3. Jika tidak ada, return default (akan dianggap error)
  // 4. Tidak ada hardcode credentials
  // ============================================================
  static String get supabaseAnonKey {
    // Prioritas 1: --dart-define
    const fromDefine = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: '',
    );
    if (fromDefine.isNotEmpty) return fromDefine;
    
    // Prioritas 2: .env
    final fromEnv = dotenv.env['SUPABASE_ANON_KEY'];
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    
    // Prioritas 3: default (akan dianggap error di initialize)
    print('⚠️ Warning: No SUPABASE_ANON_KEY found!');
    return 'YOUR_ANON_KEY';
  }

  // ============================================================
  // METHOD: initialize()
  // CARA KERJA:
  // 1. Ambil credentials dari getter (prioritas: --dart-define > .env)
  // 2. Validasi: pastikan bukan default placeholder
  // 3. Jika valid, inisialisasi Supabase dengan publishableKey
  // 4. publishableKey adalah pengganti anonKey (tidak deprecated)
  // 5. Hanya dipanggil SEKALI di main()
  // ============================================================
  static Future<void> initialize() async {
    final url = supabaseUrl;
    final key = supabaseAnonKey;
    
    // Validasi: pastikan bukan default value
    if (url.contains('YOUR_PROJECT') || key.contains('YOUR_ANON_KEY')) {
      throw Exception(
        'Supabase credentials not configured.\n'
        'Please set SUPABASE_URL and SUPABASE_ANON_KEY via:\n'
        '  1. --dart-define: flutter run --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=yyy\n'
        '  2. .env file: create .env with SUPABASE_URL=xxx and SUPABASE_ANON_KEY=yyy'
      );
    }

    // Inisialisasi Supabase dengan publishableKey (pengganti anonKey)
    await Supabase.initialize(
      url: url,
      publishableKey: key,
    );
    print('✅ Supabase connected to: $url');
  }
}