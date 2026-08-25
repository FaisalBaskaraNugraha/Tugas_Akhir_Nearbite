// FILE: lib/services/api_client.dart
// FUNGSI: Mapper error dari HTTP status code ke ApiError
// CARA KERJA:
// 1. Terima status code dan error message
// 2. Mapping ke sealed ApiError berdasarkan status code
// 3. 401 -> UnauthorizedError
// 4. 404 -> NotFoundError
// 5. 4xx -> ValidationError
// 6. 5xx -> ServerError
// 7. Lainnya -> UnknownError

import '../models/api_error.dart';

class ApiErrorMapper {
  static ApiError fromStatusCode(int statusCode, {String? message}) {
    switch (statusCode) {
      case 401:
        return UnauthorizedError(
          message: message ?? 'Sesi habis, silakan login ulang',
        );
      case 403:
        return UnauthorizedError(
          message: message ?? 'Anda tidak memiliki akses',
        );
      case 404:
        return NotFoundError(
          message: message ?? 'Data tidak ditemukan',
        );
      case 400:
      case 422:
        return ValidationError(
          message: message ?? 'Validasi gagal',
          statusCode: statusCode,
        );
      case 500:
      case 502:
      case 503:
        return ServerError(
          message: message ?? 'Terjadi kesalahan server',
          statusCode: statusCode,
        );
      default:
        if (statusCode >= 400 && statusCode < 500) {
          return ValidationError(
            message: message ?? 'Terjadi kesalahan',
            statusCode: statusCode,
          );
        }
        if (statusCode >= 500) {
          return ServerError(
            message: message ?? 'Terjadi kesalahan server',
            statusCode: statusCode,
          );
        }
        return UnknownError(
          message: message ?? 'Terjadi kesalahan yang tidak diketahui',
        );
    }
  }

  static ApiError fromException(Object e) {
    // Cek error koneksi
    if (e.toString().contains('SocketException') ||
        e.toString().contains('Connection refused') ||
        e.toString().contains('Failed host lookup') ||
        e.toString().contains('Network is unreachable') ||
        e.toString().contains('Connection timed out')) {
      return const NetworkError();
    }
    
    // Cek error timeout
    if (e.toString().contains('TimeoutException')) {
      return const NetworkError(message: 'Koneksi timeout, periksa jaringan Anda');
    }
    
    return UnknownError(message: e.toString().replaceFirst('Exception: ', ''));
  }
}