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
      final rawData = Map<String, dynamic>.from(
        response.data['data'] as Map<String, dynamic>,
      );
      final data = _normalizeModuleListData(rawData);
      final items = data['items'] as List<dynamic>?;
      if (items != null) {
        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          if (item is Map) {
            items[i] = _normalizeModuleItem(Map<String, dynamic>.from(item));
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
      final rawData = Map<String, dynamic>.from(
        response.data['data'] as Map<String, dynamic>,
      );
      final data = _normalizeModuleDetailData(rawData);
      final lessons = data['lessons'] as List<dynamic>?;
      if (lessons != null) {
        for (var i = 0; i < lessons.length; i++) {
          final lesson = lessons[i];
          if (lesson is Map) {
            lessons[i] = _normalizeModuleLesson(Map<String, dynamic>.from(lesson));
          }
        }
      }
      return ModuleDetail.fromJson(data);
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  Map<String, dynamic> _normalizeModuleListData(Map<String, dynamic> data) {
    final normalized = Map<String, dynamic>.from(data);
    normalized['summary'] = _normalizeSummary(data['summary']);
    return normalized;
  }

  Map<String, dynamic> _normalizeModuleDetailData(Map<String, dynamic> data) {
    final normalized = _normalizeModuleItem(data);
    normalized['lessons'] =
        (data['lessons'] as List<dynamic>?)
            ?.map((lesson) {
              if (lesson is Map) {
                return _normalizeModuleLesson(Map<String, dynamic>.from(lesson));
              }
              return lesson;
            })
            .toList() ??
        const <dynamic>[];
    normalized['assignments'] =
        (data['assignments'] as List<dynamic>?) ?? const <dynamic>[];
    return normalized;
  }

  Map<String, dynamic> _normalizeModuleItem(Map<String, dynamic> item) {
    final normalized = Map<String, dynamic>.from(item);
    normalized['id'] = _asInt(item['id']);
    normalized['title'] = _asString(item['title']);
    normalized['slug'] = _asString(item['slug']);
    normalized['description'] = _asNullableString(item['description']);
    normalized['sort_order'] = _asInt(item['sort_order']);
    normalized['lesson_count'] = _asInt(item['lesson_count']);
    normalized['assignments_count'] = _asInt(item['assignments_count']);
    normalized['completed_lessons'] = _asInt(item['completed_lessons']);
    normalized['progress_percentage'] = _asInt(item['progress_percentage']);
    normalized['show_progress'] = _asBool(item['show_progress']);
    normalized['status'] = _asString(item['status']);
    normalized['is_visible'] = _asBool(item['is_visible']);
    normalized['is_complete'] = _asBool(item['is_complete']);
    normalized['certificate_enabled'] = _asBool(item['certificate_enabled']);
    normalized['ebook_enabled'] = _asBool(item['ebook_enabled']);
    normalized['thumbnail_url'] =
        ApiClient.resolveUrl(_asNullableString(item['thumbnail_url']));
    return normalized;
  }

  Map<String, dynamic> _normalizeModuleLesson(Map<String, dynamic> lesson) {
    final normalized = Map<String, dynamic>.from(lesson);
    normalized['id'] = _asInt(lesson['id']);
    normalized['title'] = _asString(lesson['title']);
    normalized['sort_order'] = _asInt(lesson['sort_order']);
    normalized['has_workbook'] = _asBool(lesson['has_workbook']);
    normalized['has_video'] = _asBool(lesson['has_video']);
    normalized['has_audio'] = _asBool(lesson['has_audio']);
    normalized['has_content'] = _asBool(lesson['has_content']);
    normalized['is_locked'] = _asBool(lesson['is_locked']);
    normalized['lock_reason'] = _asNullableString(lesson['lock_reason']);
    normalized['status'] = _asString(lesson['status']);
    normalized['progress_percentage'] = _asInt(lesson['progress_percentage']);
    normalized['thumbnail_url'] =
        ApiClient.resolveUrl(_asNullableString(lesson['thumbnail_url']));
    return normalized;
  }

  Map<String, dynamic> _normalizeSummary(dynamic value) {
    final summary =
        value is Map<String, dynamic>
            ? value
            : Map<String, dynamic>.from(value as Map);
    return <String, dynamic>{
      'total': _asInt(summary['total']),
      'visible': _asInt(summary['visible']),
      'completed': _asInt(summary['completed']),
      'active': _asInt(summary['active']),
    };
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
    if (stringValue == null || stringValue.isEmpty) {
      return null;
    }
    return stringValue;
  }
}
