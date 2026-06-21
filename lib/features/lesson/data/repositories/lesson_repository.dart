import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/error/app_exception.dart';
import '../models/lesson_model.dart';

class LessonRepository {
  final Dio _dio;

  LessonRepository() : _dio = ApiClient.create();

  Future<LessonDetail> getLessonDetail(int lessonId) async {
    try {
      final response = await _dio.get('/lessons/$lessonId');
      final data = Map<String, dynamic>.from(
        response.data['data'] as Map<String, dynamic>,
      );
      _normalizeLessonUrls(data);
      return LessonDetail.fromJson(data);
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  void _normalizeLessonUrls(Map<String, dynamic> data) {
    data['thumbnail_url'] =
        ApiClient.resolveUrl(data['thumbnail_url'] as String?);

    final videoRaw = data['video'];
    if (videoRaw is Map) {
      final video = Map<String, dynamic>.from(videoRaw);
      final videoId = video['video_id'] as String?;
      final hlsUrl = video['hls_url'] as String?;
      final resolvedHlsUrl = ApiClient.resolveUrl(hlsUrl);

      // Treat partially configured video payloads as no video so the lesson
      // screen can safely fall back to thumbnail/content rendering.
      if ((videoId == null || videoId.isEmpty) &&
          (resolvedHlsUrl == null || resolvedHlsUrl.isEmpty)) {
        data['video'] = null;
      } else {
        video['hls_url'] = resolvedHlsUrl;
        data['video'] = video;
      }
    }

    final audioRaw = data['audio'];
    if (audioRaw is Map) {
      final audio = Map<String, dynamic>.from(audioRaw);
      audio['url'] = ApiClient.resolveUrl(audio['url'] as String?);
      data['audio'] = audio;
    }

    final workbookRaw = data['workbook'];
    if (workbookRaw is Map) {
      final workbook = Map<String, dynamic>.from(workbookRaw);
      workbook['url'] = ApiClient.resolveUrl(workbook['url'] as String?);
      workbook['download_url'] =
          ApiClient.resolveUrl(workbook['download_url'] as String?);
      data['workbook'] = workbook;
    }

    final navigation = data['navigation'] as List<dynamic>?;
    if (navigation != null) {
      for (var i = 0; i < navigation.length; i++) {
        final item = navigation[i];
        if (item is Map) {
          final normalized = Map<String, dynamic>.from(item);
          normalized['thumbnail_url'] =
              ApiClient.resolveUrl(normalized['thumbnail_url'] as String?);
          navigation[i] = normalized;
        }
      }
    }

    final nextLessonRaw = data['next_lesson'];
    if (nextLessonRaw is Map) {
      final nextLesson = Map<String, dynamic>.from(nextLessonRaw);
      nextLesson['thumbnail_url'] =
          ApiClient.resolveUrl(nextLesson['thumbnail_url'] as String?);
      data['next_lesson'] = nextLesson;
    }
  }

  Future<void> updateProgress(int lessonId, int progressPercent) async {
    try {
      await _dio.post('/lessons/$lessonId/progress', data: {
        'watch_progress': progressPercent,
      });
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }
}
