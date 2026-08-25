// FILE: test/unit/validator_test.dart
// FUNGSI: Unit test untuk validator

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validator Tests', () {
    String? validateName(String? value) {
      if (value == null || value.isEmpty) {
        return 'Nama menu harus diisi';
      }
      return null;
    }

    String? validatePrice(String? value) {
      if (value == null || value.isEmpty) {
        return 'Harga harus diisi';
      }
      try {
        final price = int.parse(value);
        if (price < 0) {
          return 'Harga tidak boleh negatif';
        }
      } catch (_) {
        return 'Harga harus berupa angka';
      }
      return null;
    }

    test('Nama menu validasi - empty', () {
      expect(validateName(''), 'Nama menu harus diisi');
      expect(validateName(null), 'Nama menu harus diisi');
    });

    test('Nama menu validasi - valid', () {
      expect(validateName('Nasi Goreng'), null);
      expect(validateName('Ayam Geprek'), null);
    });

    test('Harga menu validasi - empty', () {
      expect(validatePrice(''), 'Harga harus diisi');
      expect(validatePrice(null), 'Harga harus diisi');
    });

    test('Harga menu validasi - non numeric', () {
      expect(validatePrice('abc'), 'Harga harus berupa angka');
      expect(validatePrice('12abc'), 'Harga harus berupa angka');
    });

    test('Harga menu validasi - negative', () {
      expect(validatePrice('-1000'), 'Harga tidak boleh negatif');
    });

    test('Harga menu validasi - valid', () {
      expect(validatePrice('25000'), null);
      expect(validatePrice('0'), null);
    });
  });
}