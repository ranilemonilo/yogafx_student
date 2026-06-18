import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/error/app_exception.dart';
import '../models/assignment_model.dart';

class AssignmentRepository {
  final Dio _dio;

  AssignmentRepository() : _dio = ApiClient.create();

  Future<AssignmentDetail> getAssignmentDetail(int assignmentId) async {
    try {
      final response = await _dio.get('/assignments/$assignmentId');
      return AssignmentDetail.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  Future<AssignmentSubmitResponse> submitAssignment({
    required int assignmentId,
    required String filePath,
    required String fileName,
  }) async {
    try {
      final mediaType = _resolveMediaType(fileName);
      final formData = FormData.fromMap({
        'video': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: mediaType,
        ),
      });
      final response = await _dio.post(
        '/assignments/$assignmentId/submit',
        data: formData,
      );
      return AssignmentSubmitResponse.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  MediaType _resolveMediaType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.mov')) return MediaType('video', 'quicktime');
    if (lower.endsWith('.webm')) return MediaType('video', 'webm');
    if (lower.endsWith('.avi')) return MediaType('video', 'x-msvideo');
    if (lower.endsWith('.m4v')) return MediaType('video', 'x-m4v');
    return MediaType('video', 'mp4');
  }
}
