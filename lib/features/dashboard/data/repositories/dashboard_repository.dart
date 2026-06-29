import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/error/app_exception.dart';
import '../models/dashboard_model.dart';

class DashboardRepository {
  final Dio _dio;

  DashboardRepository({
    Dio? dio,
  }) : _dio = dio ?? ApiClient.create();


  Future<DashboardData> getDashboard() async {
    try {
      final response = await _dio.get('/dashboard');
      final data = Map<String, dynamic>.from(
        response.data['data'] as Map<String, dynamic>,
      );
      _normalizeThumbnailUrls(data);
      return DashboardData.fromJson(data);
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  void _normalizeThumbnailUrls(Map<String, dynamic> data) {
    final continueLearningRaw = data['continue_learning_section'];
    if (continueLearningRaw is Map) {
      continueLearningRaw['thumbnail_url'] = ApiClient.resolveUrl(
        continueLearningRaw['thumbnail_url'] as String?,
      );
    }

    final modulesSectionRaw = data['available_modules_section'];
    final items = modulesSectionRaw is Map
        ? modulesSectionRaw['items'] as List<dynamic>?
        : null;
    if (items != null) {
      for (var index = 0; index < items.length; index++) {
        final item = items[index];
        if (item is Map) {
          item['thumbnail_url'] = ApiClient.resolveUrl(
            item['thumbnail_url'] as String?,
          );
        }
      }
    }
  }
}
