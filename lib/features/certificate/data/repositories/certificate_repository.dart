import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/error/app_exception.dart';
import '../models/certificate_model.dart';

class CertificateRepository {
  final Dio _dio;

  CertificateRepository() : _dio = ApiClient.create();

  Future<CertificateListData> getCertificates() async {
    try {
      final response = await _dio.get('/certificates');
      return CertificateListData.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  Future<CertificateItem> getCertificateDetail(int certificateId) async {
    try {
      final response = await _dio.get('/certificates/$certificateId');
      final data = response.data['data'] as Map<String, dynamic>;
      return CertificateItem.fromJson(
        data['certificate'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }
}
