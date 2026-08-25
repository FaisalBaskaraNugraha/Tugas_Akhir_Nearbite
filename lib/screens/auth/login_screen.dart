// ============================================
// FILE: lib/screens/auth/login_screen.dart
// FUNGSI: Halaman Login
// ALUR: User input email & password → tekan Login → panggil AuthService.login()
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

// 📌 StatefulWidget karena ada state: loading, show/hide password
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 🔧 Controllers untuk mengambil teks dari TextFormField
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // 📊 State variables
  bool _isLoading = false;        // Untuk menampilkan loading indicator
  bool _obscurePassword = true;   // Untuk show/hide password

  // 🚀 Fungsi LOGIN - dipanggil saat tombol Login ditekan
  Future<void> _login() async {
    // ✅ Validasi form (email & password tidak boleh kosong)
    if (!_formKey.currentState!.validate()) return;

    // 🔄 Tampilkan loading
    setState(() => _isLoading = true);

    try {
      // 📌 Ambil AuthService dari Provider
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // 📤 Panggil fungsi login
      await authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // ✅ Jika berhasil, pindah ke HomeScreen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      // ❌ Jika gagal, tampilkan error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login gagal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // 🔄 Hilangkan loading
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey, // 📌 FormKey untuk validasi
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🏠 Logo
                  const Icon(
                    Icons.restaurant,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  
                  // 📌 Teks judul
                  Text(
                    'NearBite',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  
                  // 📌 Teks subtitle
                  Text(
                    'Temukan kuliner terdekat',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 48),

                  // 📧 Input Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email harus diisi';
                      }
                      if (!value.contains('@')) {
                        return 'Email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 🔒 Input Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password harus diisi';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 🚀 Tombol Login
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Login',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 📝 Link ke Register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Belum punya akun?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text('Daftar sekarang'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🧹 Bersihkan controller saat widget dihapus
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}