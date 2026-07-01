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
    final rawEbooks = _asList(
      data['ebooks'] ??
          data['ebook_items'] ??
          data['ebook_list'] ??
          data['module_ebooks'],
    );
    final rawCertificates = _asList(
      data['certificates'] ??
          data['certificate_items'] ??
          data['certificate_list'] ??
          data['module_certificates'],
    );
    final rawLessons = _asList(
      data['lessons'] ??
          data['video_lectures'] ??
          data['video_lecturer'] ??
          data['video_lecture_lessons'] ??
          data['module_lessons'],
    );
    final rawVideoLecturers = _asList(
      data['video_lecturers'] ??
          data['video_lectures'] ??
          data['video_lecturer'] ??
          data['module_video_lecturers'],
    );

    normalized['ebooks'] =
        rawEbooks
            .map((ebook) {
              if (ebook is Map) {
                return _normalizeModuleEbook(Map<String, dynamic>.from(ebook));
              }
              return ebook;
            })
            .toList();
    normalized['certificates'] =
        rawCertificates
            .map((certificate) {
              if (certificate is Map) {
                return _normalizeModuleCertificate(
                  Map<String, dynamic>.from(certificate),
                );
              }
              return certificate;
            })
            .toList();
    normalized['lessons'] =
        rawLessons
            .map((lesson) {
              if (lesson is Map) {
                return _normalizeModuleLesson(Map<String, dynamic>.from(lesson));
              }
              return lesson;
            })
            .toList();
    normalized['video_lecturers'] =
        rawVideoLecturers
            .map((video) {
              if (video is Map) {
                return _normalizeModuleVideoLecturer(
                  Map<String, dynamic>.from(video),
                );
              }
              return video;
            })
            .toList();
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
    normalized['module_type'] = _resolveModuleType(item);
    normalized['certificate_enabled'] = _asBool(item['certificate_enabled']);
    normalized['ebook_enabled'] = _asBool(item['ebook_enabled']);
    normalized['thumbnail_url'] =
        ApiClient.resolveUrl(_asNullableString(item['thumbnail_url']));
    normalized['cta_url'] = _asNullableString(item['cta_url'] ?? item['primary_cta_url']);
    normalized['cta_kind'] = _asNullableString(item['cta_kind'] ?? item['primary_cta_kind']);
    normalized['cta_label'] = _asNullableString(item['cta_label'] ?? item['primary_cta_label']);
    return normalized;
  }

  Map<String, dynamic> _normalizeModuleEbook(Map<String, dynamic> ebook) {
    final normalized = Map<String, dynamic>.from(ebook);
    final file = ebook['file'] as Map<String, dynamic>?;
    normalized['id'] = _asInt(ebook['id']);
    normalized['title'] = _asString(ebook['title']);
    normalized['sort_order'] = _asInt(ebook['sort_order']);
    normalized['file_name'] = _asNullableString(ebook['file_name']);
    normalized['preview_supported'] = _asBool(ebook['preview_supported']);
    normalized['preview_message'] = _asNullableString(ebook['preview_message']);
    normalized['mime_type'] = _asNullableString(ebook['mime_type']);
    normalized['download_url'] = _asNullableString(
      ebook['download_url'] ?? file?['download_url'] ?? file?['url'],
    );
    return normalized;
  }

  Map<String, dynamic> _normalizeModuleVideoLecturer(Map<String, dynamic> video) {
    final normalized = Map<String, dynamic>.from(video);
    final nestedVideo = video['video'] as Map<String, dynamic>?;
    final hlsUrl =
        nestedVideo?['hls_url'] ??
        video['hls_url'] ??
        video['stream_url'] ??
        video['video_url'] ??
        nestedVideo?['stream_url'] ??
        nestedVideo?['url'];

    normalized['id'] = _asInt(video['id']);
    normalized['title'] = _asString(video['title']);
    normalized['url_slug'] = _asString(video['url_slug'] ?? video['slug']);
    normalized['description'] = _asNullableString(video['description']);
    normalized['index'] = _asInt(video['index']);
    normalized['status'] = _asString(video['status']);
    normalized['thumbnail_url'] = _asNullableString(video['thumbnail_url']);
    normalized['hls_url'] = _asNullableString(hlsUrl);
    normalized['video'] = <String, dynamic>{
      ...?nestedVideo,
      'hls_url': _asNullableString(hlsUrl),
    };
    return normalized;
  }

  Map<String, dynamic> _normalizeModuleCertificate(
    Map<String, dynamic> certificate,
  ) {
    final normalized = Map<String, dynamic>.from(certificate);
    normalized['id'] = _asInt(certificate['id']);
    normalized['type'] = _asString(certificate['type']);
    normalized['type_label'] = _asString(
      certificate['type_label'] ?? certificate['title'],
    );
    normalized['file_name'] = _asNullableString(certificate['file_name']);
    normalized['generated_at'] = _asNullableString(certificate['generated_at']);
    normalized['generated_by'] = _asNullableString(certificate['generated_by']);
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

  List<dynamic> _asList(dynamic value) {
    if (value is List<dynamic>) {
      return value;
    }
    if (value is List) {
      return List<dynamic>.from(value);
    }
    if (value is Map) {
      final items = value['items'];
      if (items is List<dynamic>) {
        return items;
      }
      if (items is List) {
        return List<dynamic>.from(items);
      }
      if (value.containsKey('id') ||
          value.containsKey('title') ||
          value.containsKey('type_label')) {
        return <dynamic>[value];
      }
    }
    return const <dynamic>[];
  }

  String _resolveModuleType(Map<String, dynamic> item) {
    final directType = _canonicalizeModuleType(
      item['module_type'] ??
          item['type'] ??
          item['category'] ??
          item['module_category'],
    );
    if (directType != null) {
      return directType;
    }

    if (_asBool(item['ebook_enabled'])) {
      return 'ebook';
    }
    if (_asBool(item['certificate_enabled'])) {
      return 'certificate';
    }
    return 'lesson';
  }

  String? _canonicalizeModuleType(dynamic value) {
    final raw = value?.toString().trim().toLowerCase();
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final normalized = raw.replaceAll('-', '_').replaceAll(' ', '_');
    switch (normalized) {
      case 'ebook':
        return 'ebook';
      case 'certificate':
      case 'certification':
      case 'certificates':
        return 'certificate';
      case 'lesson':
      case 'lessons':
        return 'lesson';
      case 'video_lecture':
      case 'video_lecturer':
      case 'video_lectures':
      case 'video_lecturer_module':
      case 'video_lecture_module':
      case 'video':
        return 'video_lecture';
      default:
        return null;
    }
  }
}
