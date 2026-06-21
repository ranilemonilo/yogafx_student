// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssessmentIntroLessonImpl _$$AssessmentIntroLessonImplFromJson(
        Map<String, dynamic> json) =>
    _$AssessmentIntroLessonImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
    );

Map<String, dynamic> _$$AssessmentIntroLessonImplToJson(
        _$AssessmentIntroLessonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
    };

_$AssessmentInfoImpl _$$AssessmentInfoImplFromJson(Map<String, dynamic> json) =>
    _$AssessmentInfoImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      showProgressBar: json['show_progress_bar'] as bool,
      allowBackNavigation: json['allow_back_navigation'] as bool,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );

Map<String, dynamic> _$$AssessmentInfoImplToJson(
        _$AssessmentInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'duration_minutes': instance.durationMinutes,
      'show_progress_bar': instance.showProgressBar,
      'allow_back_navigation': instance.allowBackNavigation,
      'thumbnail_url': instance.thumbnailUrl,
    };

_$AssessmentEligibilityImpl _$$AssessmentEligibilityImplFromJson(
        Map<String, dynamic> json) =>
    _$AssessmentEligibilityImpl(
      isUnlocked: json['is_unlocked'] as bool,
      watchProgress: json['watch_progress'] as String?,
      requiresWatchProgress: json['requires_watch_progress'] as bool,
    );

Map<String, dynamic> _$$AssessmentEligibilityImplToJson(
        _$AssessmentEligibilityImpl instance) =>
    <String, dynamic>{
      'is_unlocked': instance.isUnlocked,
      'watch_progress': instance.watchProgress,
      'requires_watch_progress': instance.requiresWatchProgress,
    };

_$AssessmentIntroDataImpl _$$AssessmentIntroDataImplFromJson(
        Map<String, dynamic> json) =>
    _$AssessmentIntroDataImpl(
      lesson: AssessmentIntroLesson.fromJson(
          json['lesson'] as Map<String, dynamic>),
      assessment:
          AssessmentInfo.fromJson(json['assessment'] as Map<String, dynamic>),
      eligibility: AssessmentEligibility.fromJson(
          json['eligibility'] as Map<String, dynamic>),
      attempt: json['attempt'] as Map<String, dynamic>?,
      completedAttempt: json['completed_attempt'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$AssessmentIntroDataImplToJson(
        _$AssessmentIntroDataImpl instance) =>
    <String, dynamic>{
      'lesson': instance.lesson,
      'assessment': instance.assessment,
      'eligibility': instance.eligibility,
      'attempt': instance.attempt,
      'completed_attempt': instance.completedAttempt,
    };

_$AssessmentStartDataImpl _$$AssessmentStartDataImplFromJson(
        Map<String, dynamic> json) =>
    _$AssessmentStartDataImpl(
      mode: json['mode'] as String,
      attemptId: (json['attempt_id'] as num).toInt(),
    );

Map<String, dynamic> _$$AssessmentStartDataImplToJson(
        _$AssessmentStartDataImpl instance) =>
    <String, dynamic>{
      'mode': instance.mode,
      'attempt_id': instance.attemptId,
    };

_$AssessmentOptionImpl _$$AssessmentOptionImplFromJson(
        Map<String, dynamic> json) =>
    _$AssessmentOptionImpl(
      id: (json['id'] as num).toInt(),
      label: json['label'] as String,
      internalValue: json['internal_value'] as String,
      isCorrect: json['is_correct'] as bool,
      isOtherOption: json['is_other_option'] as bool,
      imageUrl: json['image_url'] as String?,
    );

Map<String, dynamic> _$$AssessmentOptionImplToJson(
        _$AssessmentOptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'internal_value': instance.internalValue,
      'is_correct': instance.isCorrect,
      'is_other_option': instance.isOtherOption,
      'image_url': instance.imageUrl,
    };

_$SavedAnswerImpl _$$SavedAnswerImplFromJson(Map<String, dynamic> json) =>
    _$SavedAnswerImpl(
      optionIds: (json['option_ids'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      answerText: json['answer_text'] as String?,
      answerNumber: json['answer_number'] as num?,
    );

Map<String, dynamic> _$$SavedAnswerImplToJson(_$SavedAnswerImpl instance) =>
    <String, dynamic>{
      'option_ids': instance.optionIds,
      'answer_text': instance.answerText,
      'answer_number': instance.answerNumber,
    };

_$AssessmentQuestionImpl _$$AssessmentQuestionImplFromJson(
        Map<String, dynamic> json) =>
    _$AssessmentQuestionImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      questionText: json['question_text'] as String,
      questionType: json['question_type'] as String,
      showInstruction: json['show_instruction'] as bool,
      instructionText: json['instruction_text'] as String?,
      required: json['required'] as bool,
      allowMultiSelect: json['allow_multi_select'] as bool,
      hasCorrectnessGate: json['has_correctness_gate'] as bool,
      characterLimit: (json['character_limit'] as num?)?.toInt(),
      saved: SavedAnswer.fromJson(json['saved'] as Map<String, dynamic>),
      options: (json['options'] as List<dynamic>)
          .map((e) => AssessmentOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$AssessmentQuestionImplToJson(
        _$AssessmentQuestionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'question_text': instance.questionText,
      'question_type': instance.questionType,
      'show_instruction': instance.showInstruction,
      'instruction_text': instance.instructionText,
      'required': instance.required,
      'allow_multi_select': instance.allowMultiSelect,
      'has_correctness_gate': instance.hasCorrectnessGate,
      'character_limit': instance.characterLimit,
      'saved': instance.saved,
      'options': instance.options,
    };

_$AssessmentProgressImpl _$$AssessmentProgressImplFromJson(
        Map<String, dynamic> json) =>
    _$AssessmentProgressImpl(
      current: (json['current'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$$AssessmentProgressImplToJson(
        _$AssessmentProgressImpl instance) =>
    <String, dynamic>{
      'current': instance.current,
      'total': instance.total,
    };

_$AssessmentAttemptInfoImpl _$$AssessmentAttemptInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$AssessmentAttemptInfoImpl(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String,
      expiresAt: json['expires_at'] as String?,
    );

Map<String, dynamic> _$$AssessmentAttemptInfoImplToJson(
        _$AssessmentAttemptInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'expires_at': instance.expiresAt,
    };

_$AssessmentPlayInfoImpl _$$AssessmentPlayInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$AssessmentPlayInfoImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      allowBackNavigation: json['allow_back_navigation'] as bool,
      showProgressBar: json['show_progress_bar'] as bool,
      progress:
          AssessmentProgress.fromJson(json['progress'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AssessmentPlayInfoImplToJson(
        _$AssessmentPlayInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'allow_back_navigation': instance.allowBackNavigation,
      'show_progress_bar': instance.showProgressBar,
      'progress': instance.progress,
    };

_$AssessmentAttemptDataImpl _$$AssessmentAttemptDataImplFromJson(
        Map<String, dynamic> json) =>
    _$AssessmentAttemptDataImpl(
      mode: json['mode'] as String,
      assessment: AssessmentPlayInfo.fromJson(
          json['assessment'] as Map<String, dynamic>),
      attempt: AssessmentAttemptInfo.fromJson(
          json['attempt'] as Map<String, dynamic>),
      question:
          AssessmentQuestion.fromJson(json['question'] as Map<String, dynamic>),
      canGoBack: json['can_go_back'] as bool,
      isLastQuestion: json['is_last_question'] as bool,
    );

Map<String, dynamic> _$$AssessmentAttemptDataImplToJson(
        _$AssessmentAttemptDataImpl instance) =>
    <String, dynamic>{
      'mode': instance.mode,
      'assessment': instance.assessment,
      'attempt': instance.attempt,
      'question': instance.question,
      'can_go_back': instance.canGoBack,
      'is_last_question': instance.isLastQuestion,
    };

_$AssessmentResultDataImpl _$$AssessmentResultDataImplFromJson(
        Map<String, dynamic> json) =>
    _$AssessmentResultDataImpl(
      mode: json['mode'] as String,
      attemptId: (json['attempt_id'] as num).toInt(),
      scorePercentage: (json['score_percentage'] as num?)?.toDouble(),
      correctAnswers: (json['correct_answers'] as num?)?.toInt(),
      totalQuestions: (json['total_questions'] as num?)?.toInt(),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$$AssessmentResultDataImplToJson(
        _$AssessmentResultDataImpl instance) =>
    <String, dynamic>{
      'mode': instance.mode,
      'attempt_id': instance.attemptId,
      'score_percentage': instance.scorePercentage,
      'correct_answers': instance.correctAnswers,
      'total_questions': instance.totalQuestions,
      'status': instance.status,
    };
