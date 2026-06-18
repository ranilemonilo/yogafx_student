import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/error/app_exception.dart';
import '../models/module_model.dart';

class ModuleRepository {
  final Dio _dio;

  ModuleRepository() : _dio = ApiClient.create();

  Future<ModuleListData> getModules() async {
    try {
      final response = await _dio.get('/modules');
      final data = Map<String, dynamic>.from(
        response.data['data'] as Map<String, dynamic>,
      );
      final items = data['items'] as List<dynamic>?;
      if (items != null) {
        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          if (item is Map) {
            final normalizedItem = Map<String, dynamic>.from(item);
            normalizedItem['thumbnail_url'] =
                ApiClient.resolveUrl(normalizedItem['thumbnail_url'] as String?);
            items[i] = normalizedItem;
          }
        }
      }
      return ModuleListData.fromJson(data);
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  Future<ModuleDetail> getModuleDetail(int moduleId) async {
    try {
      final response = await _dio.get('/modules/$moduleId');
      final data = Map<String, dynamic>.from(
        response.data['data'] as Map<String, dynamic>,
      );
      data['thumbnail_url'] =
          ApiClient.resolveUrl(data['thumbnail_url'] as String?);
      final lessons = data['lessons'] as List<dynamic>?;
      if (lessons != null) {
        for (var i = 0; i < lessons.length; i++) {
          final lesson = lessons[i];
          if (lesson is Map) {
            final normalizedLesson = Map<String, dynamic>.from(lesson);
            normalizedLesson['thumbnail_url'] = ApiClient.resolveUrl(
              normalizedLesson['thumbnail_url'] as String?,
            );
            lessons[i] = normalizedLesson;
          }
        }
      }
      return ModuleDetail.fromJson(data);
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }
}
