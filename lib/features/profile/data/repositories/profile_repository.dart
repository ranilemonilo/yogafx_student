import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/error/app_exception.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository() : _dio = ApiClient.create();

  Future<ProfileData> getProfile() async {
    try {
      final response = await _dio.get('/profile');
      return ProfileData.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  Future<ProfileData> updateProfile(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.patch('/profile', data: payload);
      return ProfileData.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      await _dio.post('/profile/change-password', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      });
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }
}
