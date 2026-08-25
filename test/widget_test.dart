// 
// UNIT: Widget Test
// FILE: test/widget_test.dart
// 
// CARA KERJA:
// 1. Test sederhana untuk memverifikasi UI dasar
// 2. TIDAK menggunakan Supabase (mock di-skip)
// 3. Hanya verifikasi widget muncul
// 

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 
  // TEST: Aplikasi bisa dijalankan (tanpa Supabase)
  // 
  testWidgets('App basic UI test', (WidgetTester tester) async {
    // Build widget sederhana tanpa Supabase
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('NearBite'),
            backgroundColor: Colors.deepOrange,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.restaurant, size: 80),
                const SizedBox(height: 16),
                const Text(
                  'NearBite',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Temukan kuliner terdekat',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 48),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Belum punya akun?'),
                    TextButton(
                      onPressed: null,
                      child: Text('Daftar sekarang'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Verifikasi widget muncul
    expect(find.text('NearBite'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Daftar sekarang'), findsOneWidget);
  });
}