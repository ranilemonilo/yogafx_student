import 'package:freezed_annotation/freezed_annotation.dart';

part 'assessment_model.freezed.dart';
part 'assessment_model.g.dart';

// --- Intro ---

@freezed
class AssessmentIntroLesson with _$AssessmentIntroLesson {
  const factory AssessmentIntroLesson({
    required int id,
    required String title,
  }) = _AssessmentIntroLesson;

  factory AssessmentIntroLesson.fromJson(Map<String, dynamic> json) =>
      _$AssessmentIntroLessonFromJson(json);
}

@freezed
class AssessmentInfo with _$AssessmentInfo {
  const factory AssessmentInfo({
    required int id,
    required String title,
    String? description,
    @JsonKey(name: 'duration_minutes') int? durationMinutes,
    @JsonKey(name: 'show_progress_bar') required bool showProgressBar,
    @JsonKey(name: 'allow_back_navigation') required bool allowBackNavigation,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
  }) = _AssessmentInfo;

  factory AssessmentInfo.fromJson(Map<String, dynamic> json) =>
      _$AssessmentInfoFromJson(json);
}

@freezed
class AssessmentEligibility with _$AssessmentEligibility {
  const factory AssessmentEligibility({
    @JsonKey(name: 'is_unlocked') required bool isUnlocked,
    @JsonKey(name: 'watch_progress') String? watchProgress,
    @JsonKey(name: 'requires_watch_progress') required bool requiresWatchProgress,
  }) = _AssessmentEligibility;

  factory AssessmentEligibility.fromJson(Map<String, dynamic> json) =>
      _$AssessmentEligibilityFromJson(json);
}

@freezed
class AssessmentIntroData with _$AssessmentIntroData {
  const factory AssessmentIntroData({
    required AssessmentIntroLesson lesson,
    required AssessmentInfo assessment,
    required AssessmentEligibility eligibility,
    Map<String, dynamic>? attempt,
    @JsonKey(name: 'completed_attempt') Map<String, dynamic>? completedAttempt,
  }) = _AssessmentIntroData;

  factory AssessmentIntroData.fromJson(Map<String, dynamic> json) =>
      _$AssessmentIntroDataFromJson(json);
}

// --- Start ---

@freezed
class AssessmentStartData with _$AssessmentStartData {
  const factory AssessmentStartData({
    required String mode,
    @JsonKey(name: 'attempt_id') required int attemptId,
  }) = _AssessmentStartData;

  factory AssessmentStartData.fromJson(Map<String, dynamic> json) =>
      _$AssessmentStartDataFromJson(json);
}

// --- Question ---

@freezed
class AssessmentOption with _$AssessmentOption {
  const factory AssessmentOption({
    required int id,
    required String label,
    @JsonKey(name: 'internal_value') required String internalValue,
    @JsonKey(name: 'is_correct') required bool isCorrect,
    @JsonKey(name: 'is_other_option') required bool isOtherOption,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _AssessmentOption;

  factory AssessmentOption.fromJson(Map<String, dynamic> json) =>
      _$AssessmentOptionFromJson(json);
}

@freezed
class SavedAnswer with _$SavedAnswer {
  const factory SavedAnswer({
    @JsonKey(name: 'option_ids') required List<int> optionIds,
    @JsonKey(name: 'answer_text') String? answerText,
    @JsonKey(name: 'answer_number') num? answerNumber,
  }) = _SavedAnswer;

  factory SavedAnswer.fromJson(Map<String, dynamic> json) =>
      _$SavedAnswerFromJson(json);
}

@freezed
class AssessmentQuestion with _$AssessmentQuestion {
  const factory AssessmentQuestion({
    required int id,
    required String title,
    @JsonKey(name: 'question_text') required String questionText,
    @JsonKey(name: 'question_type') required String questionType,
    @JsonKey(name: 'show_instruction') required bool showInstruction,
    @JsonKey(name: 'instruction_text') String? instructionText,
    required bool required,
    @JsonKey(name: 'allow_multi_select') required bool allowMultiSelect,
    @JsonKey(name: 'has_correctness_gate') required bool hasCorrectnessGate,
    @JsonKey(name: 'character_limit') int? characterLimit,
    required SavedAnswer saved,
    required List<AssessmentOption> options,
  }) = _AssessmentQuestion;

  factory AssessmentQuestion.fromJson(Map<String, dynamic> json) =>
      _$AssessmentQuestionFromJson(json);
}

@freezed
class AssessmentProgress with _$AssessmentProgress {
  const factory AssessmentProgress({
    required int current,
    required int total,
  }) = _AssessmentProgress;

  factory AssessmentProgress.fromJson(Map<String, dynamic> json) =>
      _$AssessmentProgressFromJson(json);
}

@freezed
class AssessmentAttemptInfo with _$AssessmentAttemptInfo {
  const factory AssessmentAttemptInfo({
    required int id,
    required String status,
    @JsonKey(name: 'expires_at') String? expiresAt,
  }) = _AssessmentAttemptInfo;

  factory AssessmentAttemptInfo.fromJson(Map<String, dynamic> json) =>
      _$AssessmentAttemptInfoFromJson(json);
}

@freezed
class AssessmentPlayInfo with _$AssessmentPlayInfo {
  const factory AssessmentPlayInfo({
    required int id,
    required String title,
    @JsonKey(name: 'allow_back_navigation') required bool allowBackNavigation,
    @JsonKey(name: 'show_progress_bar') required bool showProgressBar,
    required AssessmentProgress progress,
  }) = _AssessmentPlayInfo;

  factory AssessmentPlayInfo.fromJson(Map<String, dynamic> json) =>
      _$AssessmentPlayInfoFromJson(json);
}

@freezed
class AssessmentAttemptData with _$AssessmentAttemptData {
  const factory AssessmentAttemptData({
    required String mode,
    required AssessmentPlayInfo assessment,
    required AssessmentAttemptInfo attempt,
    required AssessmentQuestion question,
    @JsonKey(name: 'can_go_back') required bool canGoBack,
    @JsonKey(name: 'is_last_question') required bool isLastQuestion,
  }) = _AssessmentAttemptData;

  factory AssessmentAttemptData.fromJson(Map<String, dynamic> json) =>
      _$AssessmentAttemptDataFromJson(json);
}

// --- Result ---

@freezed
class AssessmentResultData with _$AssessmentResultData {
  const factory AssessmentResultData({
    required String mode,
    @JsonKey(name: 'attempt_id') required int attemptId,
  }) = _AssessmentResultData;

  factory AssessmentResultData.fromJson(Map<String, dynamic> json) =>
      _$AssessmentResultDataFromJson(json);
}
