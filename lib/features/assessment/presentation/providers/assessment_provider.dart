import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/app_exception.dart';
import '../../data/models/assessment_model.dart';
import '../../data/repositories/assessment_repository.dart';

final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  return AssessmentRepository();
});

final assessmentIntroProvider =
FutureProvider.family<AssessmentIntroData, int>((ref, lessonId) async {
  return ref.read(assessmentRepositoryProvider).getIntro(lessonId);
});

final assessmentResultProvider = FutureProvider.family<
    AssessmentResultData,
    ({int lessonId, int attemptId})>((ref, params) async {
  return ref
      .read(assessmentRepositoryProvider)
      .getResult(params.lessonId, params.attemptId);
});

// State untuk attempt yang sedang berjalan
class AssessmentAttemptNotifier
    extends StateNotifier<AsyncValue<AssessmentAttemptData?>> {
  final AssessmentRepository _repository;
  final int lessonId;
  final int attemptId;

  AssessmentAttemptNotifier({
    required AssessmentRepository repository,
    required this.lessonId,
    required this.attemptId,
  })  : _repository = repository,
        super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getAttempt(lessonId, attemptId);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> submitAnswer({
    required int questionId,
    List<int>? optionIds,
    String? answerText,
    num? answerNumber,
  }) async {
    final currentData = state.valueOrNull;
    try {
      final data = await _repository.storeAnswer(
        lessonId: lessonId,
        attemptId: attemptId,
        questionId: questionId,
        optionIds: optionIds,
        answerText: answerText,
        answerNumber: answerNumber,
      );
      state = AsyncValue.data(data);
    } catch (e, st) {
      if (currentData != null) {
        state = AsyncValue.data(currentData);
      } else {
        state = AsyncValue.error(e, st);
      }
      if (e is AppException) {
        rethrow;
      }
      throw AppException(message: e.toString());
    }
  }

  Future<void> goBack() async {
    final currentData = state.valueOrNull;
    try {
      final data = await _repository.goBack(lessonId, attemptId);
      state = AsyncValue.data(data);
    } catch (e, st) {
      if (currentData != null) {
        state = AsyncValue.data(currentData);
      } else {
        state = AsyncValue.error(e, st);
      }
      if (e is AppException) {
        rethrow;
      }
      throw AppException(message: e.toString());
    }
  }
}

final assessmentAttemptProvider = StateNotifierProvider.family<
    AssessmentAttemptNotifier,
    AsyncValue<AssessmentAttemptData?>,
    ({int lessonId, int attemptId})>((ref, params) {
  return AssessmentAttemptNotifier(
    repository: ref.read(assessmentRepositoryProvider),
    lessonId: params.lessonId,
    attemptId: params.attemptId,
  );
});
