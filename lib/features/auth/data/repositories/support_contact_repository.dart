import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/error/app_exception.dart';
import '../models/support_contact.dart';

class SupportContactRepository {
  final Dio _dio;

  SupportContactRepository({
    Dio? dio,
  }) : _dio = dio ?? ApiClient.create();

  Future<SupportContact> fetchSupportContact() async {
    try {
      final response = await _dio.get('/support-contact');
      final data = response.data;
      final payload =
          data is Map<String, dynamic>
              ? data['data']
              : data is Map
              ? Map<String, dynamic>.from(data)['data']
              : null;

      if (payload is Map<String, dynamic>) {
        return SupportContact.fromJson(payload);
      }

      if (payload is Map) {
        return SupportContact.fromJson(Map<String, dynamic>.from(payload));
      }

      return const SupportContact(whatsapp: null, email: null);
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }
}
