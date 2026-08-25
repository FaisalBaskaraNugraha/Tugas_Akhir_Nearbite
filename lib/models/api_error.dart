// FILE: lib/models/api_error.dart
// FUNGSI: Sealed class untuk menangani error API
// CARA KERJA:
// 1. NetworkError: koneksi internet mati
// 2. UnauthorizedError: 401 - token invalid / expired
// 3. NotFoundError: 404 - data tidak ditemukan
// 4. ValidationError: 4xx - validasi gagal
// 5. ServerError: 5xx - server error
// 6. UnknownError: error lain yang tidak terduga
// 7. Semua case ditangani exhaustive

sealed class ApiError {
  const ApiError();
  String get message;
}

class NetworkError extends ApiError {
  @override
  final String message;
  const NetworkError({this.message = 'Tidak ada koneksi internet'});
}

class UnauthorizedError extends ApiError {
  @override
  final String message;
  const UnauthorizedError({this.message = 'Sesi habis, silakan login ulang'});
}

class NotFoundError extends ApiError {
  @override
  final String message;
  const NotFoundError({this.message = 'Data tidak ditemukan'});
}

class ValidationError extends ApiError {
  @override
  final String message;
  final int statusCode;
  const ValidationError({
    this.message = 'Validasi gagal',
    this.statusCode = 400,
  });
}

class ServerError extends ApiError {
  @override
  final String message;
  final int statusCode;
  const ServerError({
    this.message = 'Terjadi kesalahan server',
    this.statusCode = 500,
  });
}

class UnknownError extends ApiError {
  @override
  final String message;
  const UnknownError({this.message = 'Terjadi kesalahan yang tidak diketahui'});
}