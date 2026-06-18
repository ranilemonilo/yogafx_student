import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/assessment_model.dart';
import '../../data/repositories/assessment_repository.dart';

final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  return AssessmentRepository();
});

final assessmentIntroProvider =
FutureProvider.family<AssessmentIntroData, int>((ref, lessonId) async {
  return ref.read(assessmentRepositoryProvider).getIntro(lessonId);
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
    state = const AsyncValue.loading();
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
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> goBack() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.goBack(lessonId, attemptId);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
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