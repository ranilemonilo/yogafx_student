import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/error/app_exception.dart';
import '../models/dashboard_model.dart';

class DashboardRepository {
  final Dio _dio;

  DashboardRepository() : _dio = ApiClient.create();

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
    final continueLearning = continueLearningRaw is Map
        ? Map<String, dynamic>.from(continueLearningRaw)
        : null;
    if (continueLearning != null) {
      continueLearning['thumbnail_url'] =
          ApiClient.resolveUrl(continueLearning['thumbnail_url'] as String?);
      data['continue_learning_section'] = continueLearning;
    }

    final modulesSectionRaw = data['available_modules_section'];
    final modulesSection = modulesSectionRaw is Map
        ? Map<String, dynamic>.from(modulesSectionRaw)
        : null;
    final items = modulesSection?['items'] as List<dynamic>?;
    if (items != null) {
      for (final item in items) {
        if (item is Map) {
          final normalizedItem = Map<String, dynamic>.from(item);
          normalizedItem['thumbnail_url'] =
              ApiClient.resolveUrl(normalizedItem['thumbnail_url'] as String?);
          items[items.indexOf(item)] = normalizedItem;
        }
      }
    }
    if (modulesSection != null) {
      data['available_modules_section'] = modulesSection;
    }
  }
}
