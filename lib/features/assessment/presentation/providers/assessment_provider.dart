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

class AssessmentAttemptState {
  final AssessmentAttemptData? data;
  final bool isInitialLoading;
  final bool isSubmittingAnswer;
  final bool isSubmittingBack;
  final String? fatalError;
  final String? actionError;

  const AssessmentAttemptState({
    this.data,
    this.isInitialLoading = false,
    this.isSubmittingAnswer = false,
    this.isSubmittingBack = false,
    this.fatalError,
    this.actionError,
  });

  AssessmentAttemptState copyWith({
    AssessmentAttemptData? data,
    bool? isInitialLoading,
    bool? isSubmittingAnswer,
    bool? isSubmittingBack,
    String? fatalError,
    bool clearFatalError = false,
    String? actionError,
    bool clearActionError = false,
  }) {
    return AssessmentAttemptState(
      data: data ?? this.data,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isSubmittingAnswer: isSubmittingAnswer ?? this.isSubmittingAnswer,
      isSubmittingBack: isSubmittingBack ?? this.isSubmittingBack,
      fatalError: clearFatalError ? null : (fatalError ?? this.fatalError),
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }
}

class AssessmentAttemptNotifier extends StateNotifier<AssessmentAttemptState> {
  final AssessmentRepository _repository;
  final int lessonId;
  final int attemptId;

  AssessmentAttemptNotifier({
    required AssessmentRepository repository,
    required this.lessonId,
    required this.attemptId,
  })  : _repository = repository,
        super(const AssessmentAttemptState(isInitialLoading: true)) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(
      isInitialLoading: true,
      clearFatalError: true,
      clearActionError: true,
    );

    try {
      final data = await _repository.getAttempt(lessonId, attemptId);
      state = AssessmentAttemptState(data: data);
    } catch (e) {
      state = AssessmentAttemptState(
        data: state.data,
        fatalError: _messageFromError(e),
      );
    }
  }

  Future<bool> submitAnswer({
    required int questionId,
    List<int>? optionIds,
    String? answerText,
    num? answerNumber,
  }) async {
    state = state.copyWith(
      isSubmittingAnswer: true,
      clearActionError: true,
    );

    try {
      final data = await _repository.storeAnswer(
        lessonId: lessonId,
        attemptId: attemptId,
        questionId: questionId,
        optionIds: optionIds,
        answerText: answerText,
        answerNumber: answerNumber,
      );
      state = state.copyWith(
        data: data,
        isSubmittingAnswer: false,
        clearActionError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmittingAnswer: false,
        actionError: _messageFromError(e),
      );
      return false;
    }
  }

  Future<bool> goBack() async {
    state = state.copyWith(
      isSubmittingBack: true,
      clearActionError: true,
    );

    try {
      final data = await _repository.goBack(lessonId, attemptId);
      state = state.copyWith(
        data: data,
        isSubmittingBack: false,
        clearActionError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmittingBack: false,
        actionError: _messageFromError(e),
      );
      return false;
    }
  }

  void clearActionError() {
    if (state.actionError == null) return;
    state = state.copyWith(clearActionError: true);
  }

  String _messageFromError(Object error) {
    if (error is AppException) return error.message;
    return error.toString();
  }
}

final assessmentAttemptProvider = StateNotifierProvider.family<
    AssessmentAttemptNotifier,
    AssessmentAttemptState,
    ({int lessonId, int attemptId})>((ref, params) {
  return AssessmentAttemptNotifier(
    repository: ref.read(assessmentRepositoryProvider),
    lessonId: params.lessonId,
    attemptId: params.attemptId,
  );
});

final assessmentResultProvider = FutureProvider.family<
    Map<String, dynamic>,
    ({int lessonId, int attemptId})>((ref, params) async {
  return ref
      .read(assessmentRepositoryProvider)
      .getResultPayload(params.lessonId, params.attemptId);
});
