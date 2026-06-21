import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/error/app_exception.dart';
import '../models/assessment_model.dart';

class AssessmentRepository {
  final Dio _dio;

  AssessmentRepository() : _dio = ApiClient.create();

  Map<String, dynamic>? _extractMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (key, val) => MapEntry(key.toString(), val),
      );
    }
    return null;
  }

  AssessmentAttemptData _buildRedirectAttemptData({
    required String mode,
    required int attemptId,
  }) {
    return AssessmentAttemptData(
      mode: mode,
      assessment: const AssessmentPlayInfo(
        id: 0,
        title: '',
        allowBackNavigation: false,
        showProgressBar: false,
        progress: AssessmentProgress(current: 0, total: 0),
      ),
      attempt: AssessmentAttemptInfo(
        id: attemptId,
        status: 'completed',
      ),
      question: const AssessmentQuestion(
        id: 0,
        title: '',
        questionText: '',
        questionType: 'radio_buttons',
        showInstruction: false,
        instructionText: null,
        required: false,
        allowMultiSelect: false,
        hasCorrectnessGate: false,
        characterLimit: null,
        saved: SavedAnswer(
          optionIds: [],
          answerText: null,
          answerNumber: null,
        ),
        options: [],
      ),
      canGoBack: false,
      isLastQuestion: true,
    );
  }

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
      final body = _extractMap(response.data);
      final dataMap = _extractMap(body?['data']);

      if (dataMap != null) {
        final mode = dataMap['mode'];
        if (mode == 'question_redirect' || mode == 'result_redirect') {
          return _buildRedirectAttemptData(
            mode: mode.toString(),
            attemptId: (dataMap['attempt_id'] as num?)?.toInt() ?? attemptId,
          );
        }
        return AssessmentAttemptData.fromJson(dataMap);
      }

      throw const ServerException();
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
      final body = _extractMap(response.data);
      final dataMap = _extractMap(body?['data']);

      if (dataMap != null) {
        final mode = dataMap['mode'];
        if (mode == 'question_redirect' || mode == 'result_redirect') {
          if (mode == 'question_redirect') {
            return getAttempt(lessonId, attemptId);
          }
          return _buildRedirectAttemptData(
            mode: mode.toString(),
            attemptId: (dataMap['attempt_id'] as num?)?.toInt() ?? attemptId,
          );
        }
        return AssessmentAttemptData.fromJson(dataMap);
      }

      if (body != null) {
        final rootMode = body['mode'];
        if (rootMode is String) {
          if (rootMode == 'question_redirect') {
            return getAttempt(lessonId, attemptId);
          }
          if (rootMode == 'result_redirect') {
            return _buildRedirectAttemptData(
              mode: rootMode,
              attemptId: attemptId,
            );
          }
          return AssessmentAttemptData.fromJson(body);
        }
      }

      return getAttempt(lessonId, attemptId);
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
