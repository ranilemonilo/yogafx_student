import 'package:dio/dio.dart';
import 'dart:convert';
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
      _normalizeProfileData(data);
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
      _normalizeProfileData(data);
      return ProfileData.fromJson(data);
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  void _normalizeProfileData(Map<String, dynamic> data) {
    data['id'] = _asInt(data['id']);
    data['name'] = _asString(data['name']);
    data['first_name'] = _asString(data['first_name']);
    data['last_name'] = _asString(data['last_name']);
    data['email'] = _asString(data['email']);
    data['whatsapp'] = _asNullableString(data['whatsapp']);
    data['instagram'] = _asNullableString(data['instagram']);
    data['country'] = _asNullableString(data['country']);
    data['birth_date'] = _asNullableString(data['birth_date']);
    data['gender'] = _asNullableString(data['gender']);
    data['practicing_yoga_for'] = _asNullableString(data['practicing_yoga_for']);
    data['yoga_sequence_experience'] = _normalizeChoiceValue(
      data['yoga_sequence_experience'],
    );
    data['hours_per_week'] = _asNullableString(data['hours_per_week']);
    data['current_fitness_level'] = _asNullableString(
      data['current_fitness_level'],
    );
    data['flexibility_rating'] = _asNullableString(data['flexibility_rating']);
    data['motivation'] = _asNullableString(data['motivation']);
    data['why_yogafx'] = _asNullableString(data['why_yogafx']);
    data['how_did_you_find_us'] = _normalizeChoiceValue(
      data['how_did_you_find_us'],
    );
    data['profile_photo'] = ApiClient.resolveUrl(
      _asNullableString(data['profile_photo_url'] ?? data['profile_photo']),
    );
    data['profile_completed'] = _asBool(data['profile_completed']);
    data['access_tier'] = _normalizeAccessTier(data['access_tier']);
  }

  Map<String, dynamic> _normalizeAccessTier(dynamic value) {
    final tier =
        value is Map<String, dynamic>
            ? value
            : Map<String, dynamic>.from((value as Map?) ?? const {});
    return <String, dynamic>{
      'id': _asInt(tier['id']),
      'name': _asString(tier['name']),
      'slug': _asString(tier['slug']),
    };
  }

  String? _normalizeChoiceValue(dynamic value) {
    final text = _asNullableString(value);
    if (text == null) return null;

    try {
      final decoded = jsonDecode(text);
      if (decoded is List) {
        final values =
            decoded
                .map((item) => item?.toString().trim())
                .where((item) => item != null && item!.isNotEmpty)
                .cast<String>()
                .toList();
        return values.isEmpty ? null : values.join(', ');
      }
    } catch (_) {
      // Keep original text when the backend sends a plain string.
    }

    return text;
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      switch (value.trim().toLowerCase()) {
        case 'true':
        case '1':
        case 'yes':
          return true;
        case 'false':
        case '0':
        case 'no':
          return false;
      }
    }
    return false;
  }

  String _asString(dynamic value) {
    return value?.toString() ?? '';
  }

  String? _asNullableString(dynamic value) {
    final stringValue = value?.toString().trim();
    if (stringValue == null || stringValue.isEmpty || stringValue == 'null') {
      return null;
    }
    return stringValue;
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
