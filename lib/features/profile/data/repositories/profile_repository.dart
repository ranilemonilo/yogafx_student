import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/error/app_exception.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository() : _dio = ApiClient.create();

  Future<ProfileData> getProfile() async {
    try {
      final response = await _dio.get('/profile');
      final data = Map<String, dynamic>.from(
        response.data['data'] as Map<String, dynamic>,
      );
      _normalizeProfileUrls(data);
      return ProfileData.fromJson(data);
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  Future<ProfileData> updateProfile(
    Map<String, dynamic> payload, {
    String? profilePhotoPath,
    String? profilePhotoFileName,
  }) async {
    try {
      final formMap = Map<String, dynamic>.from(payload);
      if (profilePhotoPath != null && profilePhotoFileName != null) {
        formMap['profile_photo'] = await MultipartFile.fromFile(
          profilePhotoPath,
          filename: profilePhotoFileName,
          contentType: MediaType('image', 'jpeg'),
        );
      }

      final response = await _dio.patch(
        '/profile',
        data: FormData.fromMap(formMap),
      );
      final data = Map<String, dynamic>.from(
        response.data['data'] as Map<String, dynamic>,
      );
      _normalizeProfileUrls(data);
      return ProfileData.fromJson(data);
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  void _normalizeProfileUrls(Map<String, dynamic> data) {
    data['profile_photo'] =
        ApiClient.resolveUrl((data['profile_photo_url'] ?? data['profile_photo']) as String?);
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
