import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/auth_user.dart';
import '../models/login_response.dart';
import '../models/login_otp_challenge.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository() : _dio = ApiClient.create();

  Future<LoginOtpChallenge> requestLoginOtp({
    required String email,
    required String password,
    String deviceName = 'flutter_app',
  }) async {
    try {
      final response = await _dio.post('/auth/login/request-otp', data: {
        'email': email,
        'password': password,
        'device_name': deviceName,
      });

      final data = Map<String, dynamic>.from(
        response.data['data'] as Map<String, dynamic>,
      );
      return LoginOtpChallenge.fromJson(data);
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  Future<LoginResponse> verifyLoginOtp({
    required String challengeToken,
    required String otpCode,
    String deviceName = 'flutter_app',
  }) async {
    try {
      final response = await _dio.post('/auth/login/verify-otp', data: {
        'challenge_token': challengeToken,
        'otp_code': otpCode,
        'device_name': deviceName,
      });

      final data = Map<String, dynamic>.from(
        response.data['data'] as Map<String, dynamic>,
      );
      _normalizeUserUrls(data['user']);
      final loginResponse = LoginResponse.fromJson(data);

      await SecureStorageService.saveToken(loginResponse.token);
      return loginResponse;
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  Future<LoginOtpChallenge> resendLoginOtp({
    required String challengeToken,
    String deviceName = 'flutter_app',
  }) async {
    try {
      final response = await _dio.post('/auth/login/resend-otp', data: {
        'challenge_token': challengeToken,
        'device_name': deviceName,
      });

      final data = Map<String, dynamic>.from(
        response.data['data'] as Map<String, dynamic>,
      );
      return LoginOtpChallenge.fromJson(data);
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } finally {
      await SecureStorageService.deleteToken();
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      await _dio.post('/auth/forgot-password', data: {
        'email': email,
      });
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _dio.post('/auth/reset-password', data: {
        'token': token,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  Future<AuthUser?> getCurrentUser() async {
    try {
      final response = await _dio.get('/me');
      final data = Map<String, dynamic>.from(
        response.data['data'] as Map<String, dynamic>,
      );
      _normalizeUserUrls(data);
      return AuthUser.fromJson(data);
    } on DioException catch (e) {
      final error = e.error;
      if (error is UnauthorizedException) {
        await SecureStorageService.deleteToken();
        return null;
      }
      throw error as AppException? ?? const ServerException();
    }
  }

  void _normalizeUserUrls(Object? rawUser) {
    if (rawUser is! Map) return;
    final user = Map<String, dynamic>.from(rawUser);
    user['avatar'] = ApiClient.resolveUrl(user['avatar'] as String?);
    rawUser
      ..clear()
      ..addAll(user);
  }
}
