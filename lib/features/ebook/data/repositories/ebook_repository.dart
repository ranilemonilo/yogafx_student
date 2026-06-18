import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/error/app_exception.dart';
import '../models/ebook_model.dart';

class EbookRepository {
  final Dio _dio;

  EbookRepository() : _dio = ApiClient.create();

  Future<EbookListData> getEbooks() async {
    try {
      final response = await _dio.get('/ebooks');
      return EbookListData.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  Future<EbookItem> getEbookDetail(int ebookId) async {
    try {
      final response = await _dio.get('/ebooks/$ebookId');
      return EbookItem.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }
}
