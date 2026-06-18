import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/error/app_exception.dart';
import '../models/assessment_model.dart';

class AssessmentRepository {
  final Dio _dio;

  AssessmentRepository() : _dio = ApiClient.create();

  Future<AssessmentIntroData> getIntro(int lessonId) async {
    try {
      final response = await _dio.get('/lessons/$lessonId/assessment');
      return AssessmentIntroData.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  Future<AssessmentStartData> start(int lessonId) async {
    try {
      final response =
      await _dio.post('/lessons/$lessonId/assessment/start');
      return AssessmentStartData.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  Future<AssessmentAttemptData> getAttempt(
      int lessonId, int attemptId) async {
    try {
      final response = await _dio.get(
        '/lessons/$lessonId/assessment/attempts/$attemptId',
      );
      return AssessmentAttemptData.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  Future<AssessmentAttemptData> storeAnswer({
    required int lessonId,
    required int attemptId,
    required int questionId,
    List<int>? optionIds,
    String? answerText,
    num? answerNumber,
  }) async {
    try {
      final response = await _dio.post(
        '/lessons/$lessonId/assessment/attempts/$attemptId/answer',
        data: {
          'question_id': questionId,
          if (optionIds != null) 'option_ids': optionIds,
          if (answerText != null) 'answer_text': answerText,
          if (answerNumber != null) 'answer_number': answerNumber,
        },
      );
      return AssessmentAttemptData.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  Future<AssessmentAttemptData> goBack(
      int lessonId, int attemptId) async {
    try {
      final response = await _dio.post(
        '/lessons/$lessonId/assessment/attempts/$attemptId/back',
      );
      return AssessmentAttemptData.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  Future<AssessmentResultData> getResult(
      int lessonId, int attemptId) async {
    try {
      final response = await _dio.get(
        '/lessons/$lessonId/assessment/attempts/$attemptId/result',
      );
      return AssessmentResultData.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }
}