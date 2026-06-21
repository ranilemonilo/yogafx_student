// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assessment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AssessmentIntroLesson _$AssessmentIntroLessonFromJson(
    Map<String, dynamic> json) {
  return _AssessmentIntroLesson.fromJson(json);
}

/// @nodoc
mixin _$AssessmentIntroLesson {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AssessmentIntroLessonCopyWith<AssessmentIntroLesson> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssessmentIntroLessonCopyWith<$Res> {
  factory $AssessmentIntroLessonCopyWith(AssessmentIntroLesson value,
          $Res Function(AssessmentIntroLesson) then) =
      _$AssessmentIntroLessonCopyWithImpl<$Res, AssessmentIntroLesson>;
  @useResult
  $Res call({int id, String title});
}

/// @nodoc
class _$AssessmentIntroLessonCopyWithImpl<$Res,
        $Val extends AssessmentIntroLesson>
    implements $AssessmentIntroLessonCopyWith<$Res> {
  _$AssessmentIntroLessonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AssessmentIntroLessonImplCopyWith<$Res>
    implements $AssessmentIntroLessonCopyWith<$Res> {
  factory _$$AssessmentIntroLessonImplCopyWith(
          _$AssessmentIntroLessonImpl value,
          $Res Function(_$AssessmentIntroLessonImpl) then) =
      __$$AssessmentIntroLessonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String title});
}

/// @nodoc
class __$$AssessmentIntroLessonImplCopyWithImpl<$Res>
    extends _$AssessmentIntroLessonCopyWithImpl<$Res,
        _$AssessmentIntroLessonImpl>
    implements _$$AssessmentIntroLessonImplCopyWith<$Res> {
  __$$AssessmentIntroLessonImplCopyWithImpl(_$AssessmentIntroLessonImpl _value,
      $Res Function(_$AssessmentIntroLessonImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
  }) {
    return _then(_$AssessmentIntroLessonImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssessmentIntroLessonImpl implements _AssessmentIntroLesson {
  const _$AssessmentIntroLessonImpl({required this.id, required this.title});

  factory _$AssessmentIntroLessonImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssessmentIntroLessonImplFromJson(json);

  @override
  final int id;
  @override
  final String title;

  @override
  String toString() {
    return 'AssessmentIntroLesson(id: $id, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssessmentIntroLessonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AssessmentIntroLessonImplCopyWith<_$AssessmentIntroLessonImpl>
      get copyWith => __$$AssessmentIntroLessonImplCopyWithImpl<
          _$AssessmentIntroLessonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssessmentIntroLessonImplToJson(
      this,
    );
  }
}

abstract class _AssessmentIntroLesson implements AssessmentIntroLesson {
  const factory _AssessmentIntroLesson(
      {required final int id,
      required final String title}) = _$AssessmentIntroLessonImpl;

  factory _AssessmentIntroLesson.fromJson(Map<String, dynamic> json) =
      _$AssessmentIntroLessonImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  @JsonKey(ignore: true)
  _$$AssessmentIntroLessonImplCopyWith<_$AssessmentIntroLessonImpl>
      get copyWith => throw _privateConstructorUsedError;
}

AssessmentInfo _$AssessmentInfoFromJson(Map<String, dynamic> json) {
  return _AssessmentInfo.fromJson(json);
}

/// @nodoc
mixin _$AssessmentInfo {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_minutes')
  int? get durationMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'show_progress_bar')
  bool get showProgressBar => throw _privateConstructorUsedError;
  @JsonKey(name: 'allow_back_navigation')
  bool get allowBackNavigation => throw _privateConstructorUsedError;
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AssessmentInfoCopyWith<AssessmentInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssessmentInfoCopyWith<$Res> {
  factory $AssessmentInfoCopyWith(
          AssessmentInfo value, $Res Function(AssessmentInfo) then) =
      _$AssessmentInfoCopyWithImpl<$Res, AssessmentInfo>;
  @useResult
  $Res call(
      {int id,
      String title,
      String? description,
      @JsonKey(name: 'duration_minutes') int? durationMinutes,
      @JsonKey(name: 'show_progress_bar') bool showProgressBar,
      @JsonKey(name: 'allow_back_navigation') bool allowBackNavigation,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl});
}

/// @nodoc
class _$AssessmentInfoCopyWithImpl<$Res, $Val extends AssessmentInfo>
    implements $AssessmentInfoCopyWith<$Res> {
  _$AssessmentInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? durationMinutes = freezed,
    Object? showProgressBar = null,
    Object? allowBackNavigation = null,
    Object? thumbnailUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      showProgressBar: null == showProgressBar
          ? _value.showProgressBar
          : showProgressBar // ignore: cast_nullable_to_non_nullable
              as bool,
      allowBackNavigation: null == allowBackNavigation
          ? _value.allowBackNavigation
          : allowBackNavigation // ignore: cast_nullable_to_non_nullable
              as bool,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AssessmentInfoImplCopyWith<$Res>
    implements $AssessmentInfoCopyWith<$Res> {
  factory _$$AssessmentInfoImplCopyWith(_$AssessmentInfoImpl value,
          $Res Function(_$AssessmentInfoImpl) then) =
      __$$AssessmentInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      String? description,
      @JsonKey(name: 'duration_minutes') int? durationMinutes,
      @JsonKey(name: 'show_progress_bar') bool showProgressBar,
      @JsonKey(name: 'allow_back_navigation') bool allowBackNavigation,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl});
}

/// @nodoc
class __$$AssessmentInfoImplCopyWithImpl<$Res>
    extends _$AssessmentInfoCopyWithImpl<$Res, _$AssessmentInfoImpl>
    implements _$$AssessmentInfoImplCopyWith<$Res> {
  __$$AssessmentInfoImplCopyWithImpl(
      _$AssessmentInfoImpl _value, $Res Function(_$AssessmentInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? durationMinutes = freezed,
    Object? showProgressBar = null,
    Object? allowBackNavigation = null,
    Object? thumbnailUrl = freezed,
  }) {
    return _then(_$AssessmentInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      showProgressBar: null == showProgressBar
          ? _value.showProgressBar
          : showProgressBar // ignore: cast_nullable_to_non_nullable
              as bool,
      allowBackNavigation: null == allowBackNavigation
          ? _value.allowBackNavigation
          : allowBackNavigation // ignore: cast_nullable_to_non_nullable
              as bool,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssessmentInfoImpl implements _AssessmentInfo {
  const _$AssessmentInfoImpl(
      {required this.id,
      required this.title,
      this.description,
      @JsonKey(name: 'duration_minutes') this.durationMinutes,
      @JsonKey(name: 'show_progress_bar') required this.showProgressBar,
      @JsonKey(name: 'allow_back_navigation') required this.allowBackNavigation,
      @JsonKey(name: 'thumbnail_url') this.thumbnailUrl});

  factory _$AssessmentInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssessmentInfoImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String? description;
  @override
  @JsonKey(name: 'duration_minutes')
  final int? durationMinutes;
  @override
  @JsonKey(name: 'show_progress_bar')
  final bool showProgressBar;
  @override
  @JsonKey(name: 'allow_back_navigation')
  final bool allowBackNavigation;
  @override
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  @override
  String toString() {
    return 'AssessmentInfo(id: $id, title: $title, description: $description, durationMinutes: $durationMinutes, showProgressBar: $showProgressBar, allowBackNavigation: $allowBackNavigation, thumbnailUrl: $thumbnailUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssessmentInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.showProgressBar, showProgressBar) ||
                other.showProgressBar == showProgressBar) &&
            (identical(other.allowBackNavigation, allowBackNavigation) ||
                other.allowBackNavigation == allowBackNavigation) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, description,
      durationMinutes, showProgressBar, allowBackNavigation, thumbnailUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AssessmentInfoImplCopyWith<_$AssessmentInfoImpl> get copyWith =>
      __$$AssessmentInfoImplCopyWithImpl<_$AssessmentInfoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssessmentInfoImplToJson(
      this,
    );
  }
}

abstract class _AssessmentInfo implements AssessmentInfo {
  const factory _AssessmentInfo(
      {required final int id,
      required final String title,
      final String? description,
      @JsonKey(name: 'duration_minutes') final int? durationMinutes,
      @JsonKey(name: 'show_progress_bar') required final bool showProgressBar,
      @JsonKey(name: 'allow_back_navigation')
      required final bool allowBackNavigation,
      @JsonKey(name: 'thumbnail_url')
      final String? thumbnailUrl}) = _$AssessmentInfoImpl;

  factory _AssessmentInfo.fromJson(Map<String, dynamic> json) =
      _$AssessmentInfoImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  @JsonKey(name: 'duration_minutes')
  int? get durationMinutes;
  @override
  @JsonKey(name: 'show_progress_bar')
  bool get showProgressBar;
  @override
  @JsonKey(name: 'allow_back_navigation')
  bool get allowBackNavigation;
  @override
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl;
  @override
  @JsonKey(ignore: true)
  _$$AssessmentInfoImplCopyWith<_$AssessmentInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AssessmentEligibility _$AssessmentEligibilityFromJson(
    Map<String, dynamic> json) {
  return _AssessmentEligibility.fromJson(json);
}

/// @nodoc
mixin _$AssessmentEligibility {
  @JsonKey(name: 'is_unlocked')
  bool get isUnlocked => throw _privateConstructorUsedError;
  @JsonKey(name: 'watch_progress')
  String? get watchProgress => throw _privateConstructorUsedError;
  @JsonKey(name: 'requires_watch_progress')
  bool get requiresWatchProgress => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AssessmentEligibilityCopyWith<AssessmentEligibility> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssessmentEligibilityCopyWith<$Res> {
  factory $AssessmentEligibilityCopyWith(AssessmentEligibility value,
          $Res Function(AssessmentEligibility) then) =
      _$AssessmentEligibilityCopyWithImpl<$Res, AssessmentEligibility>;
  @useResult
  $Res call(
      {@JsonKey(name: 'is_unlocked') bool isUnlocked,
      @JsonKey(name: 'watch_progress') String? watchProgress,
      @JsonKey(name: 'requires_watch_progress') bool requiresWatchProgress});
}

/// @nodoc
class _$AssessmentEligibilityCopyWithImpl<$Res,
        $Val extends AssessmentEligibility>
    implements $AssessmentEligibilityCopyWith<$Res> {
  _$AssessmentEligibilityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isUnlocked = null,
    Object? watchProgress = null,
    Object? requiresWatchProgress = null,
  }) {
    return _then(_value.copyWith(
      isUnlocked: null == isUnlocked
          ? _value.isUnlocked
          : isUnlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      watchProgress: freezed == watchProgress
          ? _value.watchProgress
          : watchProgress // ignore: cast_nullable_to_non_nullable
              as String?,
      requiresWatchProgress: null == requiresWatchProgress
          ? _value.requiresWatchProgress
          : requiresWatchProgress // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AssessmentEligibilityImplCopyWith<$Res>
    implements $AssessmentEligibilityCopyWith<$Res> {
  factory _$$AssessmentEligibilityImplCopyWith(
          _$AssessmentEligibilityImpl value,
          $Res Function(_$AssessmentEligibilityImpl) then) =
      __$$AssessmentEligibilityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'is_unlocked') bool isUnlocked,
      @JsonKey(name: 'watch_progress') String? watchProgress,
      @JsonKey(name: 'requires_watch_progress') bool requiresWatchProgress});
}

/// @nodoc
class __$$AssessmentEligibilityImplCopyWithImpl<$Res>
    extends _$AssessmentEligibilityCopyWithImpl<$Res,
        _$AssessmentEligibilityImpl>
    implements _$$AssessmentEligibilityImplCopyWith<$Res> {
  __$$AssessmentEligibilityImplCopyWithImpl(_$AssessmentEligibilityImpl _value,
      $Res Function(_$AssessmentEligibilityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isUnlocked = null,
    Object? watchProgress = freezed,
    Object? requiresWatchProgress = null,
  }) {
    return _then(_$AssessmentEligibilityImpl(
      isUnlocked: null == isUnlocked
          ? _value.isUnlocked
          : isUnlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      watchProgress: freezed == watchProgress
          ? _value.watchProgress
          : watchProgress // ignore: cast_nullable_to_non_nullable
              as String?,
      requiresWatchProgress: null == requiresWatchProgress
          ? _value.requiresWatchProgress
          : requiresWatchProgress // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssessmentEligibilityImpl implements _AssessmentEligibility {
  const _$AssessmentEligibilityImpl(
      {@JsonKey(name: 'is_unlocked') required this.isUnlocked,
      @JsonKey(name: 'watch_progress') this.watchProgress,
      @JsonKey(name: 'requires_watch_progress')
      required this.requiresWatchProgress});

  factory _$AssessmentEligibilityImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssessmentEligibilityImplFromJson(json);

  @override
  @JsonKey(name: 'is_unlocked')
  final bool isUnlocked;
  @override
  @JsonKey(name: 'watch_progress')
  final String? watchProgress;
  @override
  @JsonKey(name: 'requires_watch_progress')
  final bool requiresWatchProgress;

  @override
  String toString() {
    return 'AssessmentEligibility(isUnlocked: $isUnlocked, watchProgress: $watchProgress, requiresWatchProgress: $requiresWatchProgress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssessmentEligibilityImpl &&
            (identical(other.isUnlocked, isUnlocked) ||
                other.isUnlocked == isUnlocked) &&
            (identical(other.watchProgress, watchProgress) ||
                other.watchProgress == watchProgress) &&
            (identical(other.requiresWatchProgress, requiresWatchProgress) ||
                other.requiresWatchProgress == requiresWatchProgress));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, isUnlocked, watchProgress, requiresWatchProgress);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AssessmentEligibilityImplCopyWith<_$AssessmentEligibilityImpl>
      get copyWith => __$$AssessmentEligibilityImplCopyWithImpl<
          _$AssessmentEligibilityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssessmentEligibilityImplToJson(
      this,
    );
  }
}

abstract class _AssessmentEligibility implements AssessmentEligibility {
  const factory _AssessmentEligibility(
      {@JsonKey(name: 'is_unlocked') required final bool isUnlocked,
      @JsonKey(name: 'watch_progress') final String? watchProgress,
      @JsonKey(name: 'requires_watch_progress')
      required final bool requiresWatchProgress}) = _$AssessmentEligibilityImpl;

  factory _AssessmentEligibility.fromJson(Map<String, dynamic> json) =
      _$AssessmentEligibilityImpl.fromJson;

  @override
  @JsonKey(name: 'is_unlocked')
  bool get isUnlocked;
  @override
  @JsonKey(name: 'watch_progress')
  String? get watchProgress;
  @override
  @JsonKey(name: 'requires_watch_progress')
  bool get requiresWatchProgress;
  @override
  @JsonKey(ignore: true)
  _$$AssessmentEligibilityImplCopyWith<_$AssessmentEligibilityImpl>
      get copyWith => throw _privateConstructorUsedError;
}

AssessmentIntroData _$AssessmentIntroDataFromJson(Map<String, dynamic> json) {
  return _AssessmentIntroData.fromJson(json);
}

/// @nodoc
mixin _$AssessmentIntroData {
  AssessmentIntroLesson get lesson => throw _privateConstructorUsedError;
  AssessmentInfo get assessment => throw _privateConstructorUsedError;
  AssessmentEligibility get eligibility => throw _privateConstructorUsedError;
  Map<String, dynamic>? get attempt => throw _privateConstructorUsedError;
  @JsonKey(name: 'completed_attempt')
  Map<String, dynamic>? get completedAttempt =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AssessmentIntroDataCopyWith<AssessmentIntroData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssessmentIntroDataCopyWith<$Res> {
  factory $AssessmentIntroDataCopyWith(
          AssessmentIntroData value, $Res Function(AssessmentIntroData) then) =
      _$AssessmentIntroDataCopyWithImpl<$Res, AssessmentIntroData>;
  @useResult
  $Res call(
      {AssessmentIntroLesson lesson,
      AssessmentInfo assessment,
      AssessmentEligibility eligibility,
      Map<String, dynamic>? attempt,
      @JsonKey(name: 'completed_attempt')
      Map<String, dynamic>? completedAttempt});

  $AssessmentIntroLessonCopyWith<$Res> get lesson;
  $AssessmentInfoCopyWith<$Res> get assessment;
  $AssessmentEligibilityCopyWith<$Res> get eligibility;
}

/// @nodoc
class _$AssessmentIntroDataCopyWithImpl<$Res, $Val extends AssessmentIntroData>
    implements $AssessmentIntroDataCopyWith<$Res> {
  _$AssessmentIntroDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lesson = null,
    Object? assessment = null,
    Object? eligibility = null,
    Object? attempt = freezed,
    Object? completedAttempt = freezed,
  }) {
    return _then(_value.copyWith(
      lesson: null == lesson
          ? _value.lesson
          : lesson // ignore: cast_nullable_to_non_nullable
              as AssessmentIntroLesson,
      assessment: null == assessment
          ? _value.assessment
          : assessment // ignore: cast_nullable_to_non_nullable
              as AssessmentInfo,
      eligibility: null == eligibility
          ? _value.eligibility
          : eligibility // ignore: cast_nullable_to_non_nullable
              as AssessmentEligibility,
      attempt: freezed == attempt
          ? _value.attempt
          : attempt // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      completedAttempt: freezed == completedAttempt
          ? _value.completedAttempt
          : completedAttempt // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AssessmentIntroLessonCopyWith<$Res> get lesson {
    return $AssessmentIntroLessonCopyWith<$Res>(_value.lesson, (value) {
      return _then(_value.copyWith(lesson: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AssessmentInfoCopyWith<$Res> get assessment {
    return $AssessmentInfoCopyWith<$Res>(_value.assessment, (value) {
      return _then(_value.copyWith(assessment: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AssessmentEligibilityCopyWith<$Res> get eligibility {
    return $AssessmentEligibilityCopyWith<$Res>(_value.eligibility, (value) {
      return _then(_value.copyWith(eligibility: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AssessmentIntroDataImplCopyWith<$Res>
    implements $AssessmentIntroDataCopyWith<$Res> {
  factory _$$AssessmentIntroDataImplCopyWith(_$AssessmentIntroDataImpl value,
          $Res Function(_$AssessmentIntroDataImpl) then) =
      __$$AssessmentIntroDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AssessmentIntroLesson lesson,
      AssessmentInfo assessment,
      AssessmentEligibility eligibility,
      Map<String, dynamic>? attempt,
      @JsonKey(name: 'completed_attempt')
      Map<String, dynamic>? completedAttempt});

  @override
  $AssessmentIntroLessonCopyWith<$Res> get lesson;
  @override
  $AssessmentInfoCopyWith<$Res> get assessment;
  @override
  $AssessmentEligibilityCopyWith<$Res> get eligibility;
}

/// @nodoc
class __$$AssessmentIntroDataImplCopyWithImpl<$Res>
    extends _$AssessmentIntroDataCopyWithImpl<$Res, _$AssessmentIntroDataImpl>
    implements _$$AssessmentIntroDataImplCopyWith<$Res> {
  __$$AssessmentIntroDataImplCopyWithImpl(_$AssessmentIntroDataImpl _value,
      $Res Function(_$AssessmentIntroDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lesson = null,
    Object? assessment = null,
    Object? eligibility = null,
    Object? attempt = freezed,
    Object? completedAttempt = freezed,
  }) {
    return _then(_$AssessmentIntroDataImpl(
      lesson: null == lesson
          ? _value.lesson
          : lesson // ignore: cast_nullable_to_non_nullable
              as AssessmentIntroLesson,
      assessment: null == assessment
          ? _value.assessment
          : assessment // ignore: cast_nullable_to_non_nullable
              as AssessmentInfo,
      eligibility: null == eligibility
          ? _value.eligibility
          : eligibility // ignore: cast_nullable_to_non_nullable
              as AssessmentEligibility,
      attempt: freezed == attempt
          ? _value._attempt
          : attempt // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      completedAttempt: freezed == completedAttempt
          ? _value._completedAttempt
          : completedAttempt // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssessmentIntroDataImpl implements _AssessmentIntroData {
  const _$AssessmentIntroDataImpl(
      {required this.lesson,
      required this.assessment,
      required this.eligibility,
      final Map<String, dynamic>? attempt,
      @JsonKey(name: 'completed_attempt')
      final Map<String, dynamic>? completedAttempt})
      : _attempt = attempt,
        _completedAttempt = completedAttempt;

  factory _$AssessmentIntroDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssessmentIntroDataImplFromJson(json);

  @override
  final AssessmentIntroLesson lesson;
  @override
  final AssessmentInfo assessment;
  @override
  final AssessmentEligibility eligibility;
  final Map<String, dynamic>? _attempt;
  @override
  Map<String, dynamic>? get attempt {
    final value = _attempt;
    if (value == null) return null;
    if (_attempt is EqualUnmodifiableMapView) return _attempt;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _completedAttempt;
  @override
  @JsonKey(name: 'completed_attempt')
  Map<String, dynamic>? get completedAttempt {
    final value = _completedAttempt;
    if (value == null) return null;
    if (_completedAttempt is EqualUnmodifiableMapView) return _completedAttempt;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AssessmentIntroData(lesson: $lesson, assessment: $assessment, eligibility: $eligibility, attempt: $attempt, completedAttempt: $completedAttempt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssessmentIntroDataImpl &&
            (identical(other.lesson, lesson) || other.lesson == lesson) &&
            (identical(other.assessment, assessment) ||
                other.assessment == assessment) &&
            (identical(other.eligibility, eligibility) ||
                other.eligibility == eligibility) &&
            const DeepCollectionEquality().equals(other._attempt, _attempt) &&
            const DeepCollectionEquality()
                .equals(other._completedAttempt, _completedAttempt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      lesson,
      assessment,
      eligibility,
      const DeepCollectionEquality().hash(_attempt),
      const DeepCollectionEquality().hash(_completedAttempt));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AssessmentIntroDataImplCopyWith<_$AssessmentIntroDataImpl> get copyWith =>
      __$$AssessmentIntroDataImplCopyWithImpl<_$AssessmentIntroDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssessmentIntroDataImplToJson(
      this,
    );
  }
}

abstract class _AssessmentIntroData implements AssessmentIntroData {
  const factory _AssessmentIntroData(
          {required final AssessmentIntroLesson lesson,
          required final AssessmentInfo assessment,
          required final AssessmentEligibility eligibility,
          final Map<String, dynamic>? attempt,
          @JsonKey(name: 'completed_attempt')
          final Map<String, dynamic>? completedAttempt}) =
      _$AssessmentIntroDataImpl;

  factory _AssessmentIntroData.fromJson(Map<String, dynamic> json) =
      _$AssessmentIntroDataImpl.fromJson;

  @override
  AssessmentIntroLesson get lesson;
  @override
  AssessmentInfo get assessment;
  @override
  AssessmentEligibility get eligibility;
  @override
  Map<String, dynamic>? get attempt;
  @override
  @JsonKey(name: 'completed_attempt')
  Map<String, dynamic>? get completedAttempt;
  @override
  @JsonKey(ignore: true)
  _$$AssessmentIntroDataImplCopyWith<_$AssessmentIntroDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AssessmentStartData _$AssessmentStartDataFromJson(Map<String, dynamic> json) {
  return _AssessmentStartData.fromJson(json);
}

/// @nodoc
mixin _$AssessmentStartData {
  String get mode => throw _privateConstructorUsedError;
  @JsonKey(name: 'attempt_id')
  int get attemptId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AssessmentStartDataCopyWith<AssessmentStartData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssessmentStartDataCopyWith<$Res> {
  factory $AssessmentStartDataCopyWith(
          AssessmentStartData value, $Res Function(AssessmentStartData) then) =
      _$AssessmentStartDataCopyWithImpl<$Res, AssessmentStartData>;
  @useResult
  $Res call({String mode, @JsonKey(name: 'attempt_id') int attemptId});
}

/// @nodoc
class _$AssessmentStartDataCopyWithImpl<$Res, $Val extends AssessmentStartData>
    implements $AssessmentStartDataCopyWith<$Res> {
  _$AssessmentStartDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? attemptId = null,
  }) {
    return _then(_value.copyWith(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String,
      attemptId: null == attemptId
          ? _value.attemptId
          : attemptId // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AssessmentStartDataImplCopyWith<$Res>
    implements $AssessmentStartDataCopyWith<$Res> {
  factory _$$AssessmentStartDataImplCopyWith(_$AssessmentStartDataImpl value,
          $Res Function(_$AssessmentStartDataImpl) then) =
      __$$AssessmentStartDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String mode, @JsonKey(name: 'attempt_id') int attemptId});
}

/// @nodoc
class __$$AssessmentStartDataImplCopyWithImpl<$Res>
    extends _$AssessmentStartDataCopyWithImpl<$Res, _$AssessmentStartDataImpl>
    implements _$$AssessmentStartDataImplCopyWith<$Res> {
  __$$AssessmentStartDataImplCopyWithImpl(_$AssessmentStartDataImpl _value,
      $Res Function(_$AssessmentStartDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? attemptId = null,
  }) {
    return _then(_$AssessmentStartDataImpl(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String,
      attemptId: null == attemptId
          ? _value.attemptId
          : attemptId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssessmentStartDataImpl implements _AssessmentStartData {
  const _$AssessmentStartDataImpl(
      {required this.mode,
      @JsonKey(name: 'attempt_id') required this.attemptId});

  factory _$AssessmentStartDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssessmentStartDataImplFromJson(json);

  @override
  final String mode;
  @override
  @JsonKey(name: 'attempt_id')
  final int attemptId;

  @override
  String toString() {
    return 'AssessmentStartData(mode: $mode, attemptId: $attemptId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssessmentStartDataImpl &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.attemptId, attemptId) ||
                other.attemptId == attemptId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, mode, attemptId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AssessmentStartDataImplCopyWith<_$AssessmentStartDataImpl> get copyWith =>
      __$$AssessmentStartDataImplCopyWithImpl<_$AssessmentStartDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssessmentStartDataImplToJson(
      this,
    );
  }
}

abstract class _AssessmentStartData implements AssessmentStartData {
  const factory _AssessmentStartData(
          {required final String mode,
          @JsonKey(name: 'attempt_id') required final int attemptId}) =
      _$AssessmentStartDataImpl;

  factory _AssessmentStartData.fromJson(Map<String, dynamic> json) =
      _$AssessmentStartDataImpl.fromJson;

  @override
  String get mode;
  @override
  @JsonKey(name: 'attempt_id')
  int get attemptId;
  @override
  @JsonKey(ignore: true)
  _$$AssessmentStartDataImplCopyWith<_$AssessmentStartDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AssessmentOption _$AssessmentOptionFromJson(Map<String, dynamic> json) {
  return _AssessmentOption.fromJson(json);
}

/// @nodoc
mixin _$AssessmentOption {
  int get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  @JsonKey(name: 'internal_value')
  String get internalValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_correct')
  bool get isCorrect => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_other_option')
  bool get isOtherOption => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AssessmentOptionCopyWith<AssessmentOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssessmentOptionCopyWith<$Res> {
  factory $AssessmentOptionCopyWith(
          AssessmentOption value, $Res Function(AssessmentOption) then) =
      _$AssessmentOptionCopyWithImpl<$Res, AssessmentOption>;
  @useResult
  $Res call(
      {int id,
      String label,
      @JsonKey(name: 'internal_value') String internalValue,
      @JsonKey(name: 'is_correct') bool isCorrect,
      @JsonKey(name: 'is_other_option') bool isOtherOption,
      @JsonKey(name: 'image_url') String? imageUrl});
}

/// @nodoc
class _$AssessmentOptionCopyWithImpl<$Res, $Val extends AssessmentOption>
    implements $AssessmentOptionCopyWith<$Res> {
  _$AssessmentOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? internalValue = null,
    Object? isCorrect = null,
    Object? isOtherOption = null,
    Object? imageUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      internalValue: null == internalValue
          ? _value.internalValue
          : internalValue // ignore: cast_nullable_to_non_nullable
              as String,
      isCorrect: null == isCorrect
          ? _value.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
      isOtherOption: null == isOtherOption
          ? _value.isOtherOption
          : isOtherOption // ignore: cast_nullable_to_non_nullable
              as bool,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AssessmentOptionImplCopyWith<$Res>
    implements $AssessmentOptionCopyWith<$Res> {
  factory _$$AssessmentOptionImplCopyWith(_$AssessmentOptionImpl value,
          $Res Function(_$AssessmentOptionImpl) then) =
      __$$AssessmentOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String label,
      @JsonKey(name: 'internal_value') String internalValue,
      @JsonKey(name: 'is_correct') bool isCorrect,
      @JsonKey(name: 'is_other_option') bool isOtherOption,
      @JsonKey(name: 'image_url') String? imageUrl});
}

/// @nodoc
class __$$AssessmentOptionImplCopyWithImpl<$Res>
    extends _$AssessmentOptionCopyWithImpl<$Res, _$AssessmentOptionImpl>
    implements _$$AssessmentOptionImplCopyWith<$Res> {
  __$$AssessmentOptionImplCopyWithImpl(_$AssessmentOptionImpl _value,
      $Res Function(_$AssessmentOptionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? internalValue = null,
    Object? isCorrect = null,
    Object? isOtherOption = null,
    Object? imageUrl = freezed,
  }) {
    return _then(_$AssessmentOptionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      internalValue: null == internalValue
          ? _value.internalValue
          : internalValue // ignore: cast_nullable_to_non_nullable
              as String,
      isCorrect: null == isCorrect
          ? _value.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
      isOtherOption: null == isOtherOption
          ? _value.isOtherOption
          : isOtherOption // ignore: cast_nullable_to_non_nullable
              as bool,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssessmentOptionImpl implements _AssessmentOption {
  const _$AssessmentOptionImpl(
      {required this.id,
      required this.label,
      @JsonKey(name: 'internal_value') required this.internalValue,
      @JsonKey(name: 'is_correct') required this.isCorrect,
      @JsonKey(name: 'is_other_option') required this.isOtherOption,
      @JsonKey(name: 'image_url') this.imageUrl});

  factory _$AssessmentOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssessmentOptionImplFromJson(json);

  @override
  final int id;
  @override
  final String label;
  @override
  @JsonKey(name: 'internal_value')
  final String internalValue;
  @override
  @JsonKey(name: 'is_correct')
  final bool isCorrect;
  @override
  @JsonKey(name: 'is_other_option')
  final bool isOtherOption;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  @override
  String toString() {
    return 'AssessmentOption(id: $id, label: $label, internalValue: $internalValue, isCorrect: $isCorrect, isOtherOption: $isOtherOption, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssessmentOptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.internalValue, internalValue) ||
                other.internalValue == internalValue) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.isOtherOption, isOtherOption) ||
                other.isOtherOption == isOtherOption) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, label, internalValue,
      isCorrect, isOtherOption, imageUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AssessmentOptionImplCopyWith<_$AssessmentOptionImpl> get copyWith =>
      __$$AssessmentOptionImplCopyWithImpl<_$AssessmentOptionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssessmentOptionImplToJson(
      this,
    );
  }
}

abstract class _AssessmentOption implements AssessmentOption {
  const factory _AssessmentOption(
          {required final int id,
          required final String label,
          @JsonKey(name: 'internal_value') required final String internalValue,
          @JsonKey(name: 'is_correct') required final bool isCorrect,
          @JsonKey(name: 'is_other_option') required final bool isOtherOption,
          @JsonKey(name: 'image_url') final String? imageUrl}) =
      _$AssessmentOptionImpl;

  factory _AssessmentOption.fromJson(Map<String, dynamic> json) =
      _$AssessmentOptionImpl.fromJson;

  @override
  int get id;
  @override
  String get label;
  @override
  @JsonKey(name: 'internal_value')
  String get internalValue;
  @override
  @JsonKey(name: 'is_correct')
  bool get isCorrect;
  @override
  @JsonKey(name: 'is_other_option')
  bool get isOtherOption;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  @JsonKey(ignore: true)
  _$$AssessmentOptionImplCopyWith<_$AssessmentOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SavedAnswer _$SavedAnswerFromJson(Map<String, dynamic> json) {
  return _SavedAnswer.fromJson(json);
}

/// @nodoc
mixin _$SavedAnswer {
  @JsonKey(name: 'option_ids')
  List<int> get optionIds => throw _privateConstructorUsedError;
  @JsonKey(name: 'answer_text')
  String? get answerText => throw _privateConstructorUsedError;
  @JsonKey(name: 'answer_number')
  num? get answerNumber => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SavedAnswerCopyWith<SavedAnswer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SavedAnswerCopyWith<$Res> {
  factory $SavedAnswerCopyWith(
          SavedAnswer value, $Res Function(SavedAnswer) then) =
      _$SavedAnswerCopyWithImpl<$Res, SavedAnswer>;
  @useResult
  $Res call(
      {@JsonKey(name: 'option_ids') List<int> optionIds,
      @JsonKey(name: 'answer_text') String? answerText,
      @JsonKey(name: 'answer_number') num? answerNumber});
}

/// @nodoc
class _$SavedAnswerCopyWithImpl<$Res, $Val extends SavedAnswer>
    implements $SavedAnswerCopyWith<$Res> {
  _$SavedAnswerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? optionIds = null,
    Object? answerText = freezed,
    Object? answerNumber = freezed,
  }) {
    return _then(_value.copyWith(
      optionIds: null == optionIds
          ? _value.optionIds
          : optionIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
      answerText: freezed == answerText
          ? _value.answerText
          : answerText // ignore: cast_nullable_to_non_nullable
              as String?,
      answerNumber: freezed == answerNumber
          ? _value.answerNumber
          : answerNumber // ignore: cast_nullable_to_non_nullable
              as num?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SavedAnswerImplCopyWith<$Res>
    implements $SavedAnswerCopyWith<$Res> {
  factory _$$SavedAnswerImplCopyWith(
          _$SavedAnswerImpl value, $Res Function(_$SavedAnswerImpl) then) =
      __$$SavedAnswerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'option_ids') List<int> optionIds,
      @JsonKey(name: 'answer_text') String? answerText,
      @JsonKey(name: 'answer_number') num? answerNumber});
}

/// @nodoc
class __$$SavedAnswerImplCopyWithImpl<$Res>
    extends _$SavedAnswerCopyWithImpl<$Res, _$SavedAnswerImpl>
    implements _$$SavedAnswerImplCopyWith<$Res> {
  __$$SavedAnswerImplCopyWithImpl(
      _$SavedAnswerImpl _value, $Res Function(_$SavedAnswerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? optionIds = null,
    Object? answerText = freezed,
    Object? answerNumber = freezed,
  }) {
    return _then(_$SavedAnswerImpl(
      optionIds: null == optionIds
          ? _value._optionIds
          : optionIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
      answerText: freezed == answerText
          ? _value.answerText
          : answerText // ignore: cast_nullable_to_non_nullable
              as String?,
      answerNumber: freezed == answerNumber
          ? _value.answerNumber
          : answerNumber // ignore: cast_nullable_to_non_nullable
              as num?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SavedAnswerImpl implements _SavedAnswer {
  const _$SavedAnswerImpl(
      {@JsonKey(name: 'option_ids') required final List<int> optionIds,
      @JsonKey(name: 'answer_text') this.answerText,
      @JsonKey(name: 'answer_number') this.answerNumber})
      : _optionIds = optionIds;

  factory _$SavedAnswerImpl.fromJson(Map<String, dynamic> json) =>
      _$$SavedAnswerImplFromJson(json);

  final List<int> _optionIds;
  @override
  @JsonKey(name: 'option_ids')
  List<int> get optionIds {
    if (_optionIds is EqualUnmodifiableListView) return _optionIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_optionIds);
  }

  @override
  @JsonKey(name: 'answer_text')
  final String? answerText;
  @override
  @JsonKey(name: 'answer_number')
  final num? answerNumber;

  @override
  String toString() {
    return 'SavedAnswer(optionIds: $optionIds, answerText: $answerText, answerNumber: $answerNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SavedAnswerImpl &&
            const DeepCollectionEquality()
                .equals(other._optionIds, _optionIds) &&
            (identical(other.answerText, answerText) ||
                other.answerText == answerText) &&
            (identical(other.answerNumber, answerNumber) ||
                other.answerNumber == answerNumber));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_optionIds),
      answerText,
      answerNumber);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SavedAnswerImplCopyWith<_$SavedAnswerImpl> get copyWith =>
      __$$SavedAnswerImplCopyWithImpl<_$SavedAnswerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SavedAnswerImplToJson(
      this,
    );
  }
}

abstract class _SavedAnswer implements SavedAnswer {
  const factory _SavedAnswer(
          {@JsonKey(name: 'option_ids') required final List<int> optionIds,
          @JsonKey(name: 'answer_text') final String? answerText,
          @JsonKey(name: 'answer_number') final num? answerNumber}) =
      _$SavedAnswerImpl;

  factory _SavedAnswer.fromJson(Map<String, dynamic> json) =
      _$SavedAnswerImpl.fromJson;

  @override
  @JsonKey(name: 'option_ids')
  List<int> get optionIds;
  @override
  @JsonKey(name: 'answer_text')
  String? get answerText;
  @override
  @JsonKey(name: 'answer_number')
  num? get answerNumber;
  @override
  @JsonKey(ignore: true)
  _$$SavedAnswerImplCopyWith<_$SavedAnswerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AssessmentQuestion _$AssessmentQuestionFromJson(Map<String, dynamic> json) {
  return _AssessmentQuestion.fromJson(json);
}

/// @nodoc
mixin _$AssessmentQuestion {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'question_text')
  String get questionText => throw _privateConstructorUsedError;
  @JsonKey(name: 'question_type')
  String get questionType => throw _privateConstructorUsedError;
  @JsonKey(name: 'show_instruction')
  bool get showInstruction => throw _privateConstructorUsedError;
  @JsonKey(name: 'instruction_text')
  String? get instructionText => throw _privateConstructorUsedError;
  bool get required => throw _privateConstructorUsedError;
  @JsonKey(name: 'allow_multi_select')
  bool get allowMultiSelect => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_correctness_gate')
  bool get hasCorrectnessGate => throw _privateConstructorUsedError;
  @JsonKey(name: 'character_limit')
  int? get characterLimit => throw _privateConstructorUsedError;
  SavedAnswer get saved => throw _privateConstructorUsedError;
  List<AssessmentOption> get options => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AssessmentQuestionCopyWith<AssessmentQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssessmentQuestionCopyWith<$Res> {
  factory $AssessmentQuestionCopyWith(
          AssessmentQuestion value, $Res Function(AssessmentQuestion) then) =
      _$AssessmentQuestionCopyWithImpl<$Res, AssessmentQuestion>;
  @useResult
  $Res call(
      {int id,
      String title,
      @JsonKey(name: 'question_text') String questionText,
      @JsonKey(name: 'question_type') String questionType,
      @JsonKey(name: 'show_instruction') bool showInstruction,
      @JsonKey(name: 'instruction_text') String? instructionText,
      bool required,
      @JsonKey(name: 'allow_multi_select') bool allowMultiSelect,
      @JsonKey(name: 'has_correctness_gate') bool hasCorrectnessGate,
      @JsonKey(name: 'character_limit') int? characterLimit,
      SavedAnswer saved,
      List<AssessmentOption> options});

  $SavedAnswerCopyWith<$Res> get saved;
}

/// @nodoc
class _$AssessmentQuestionCopyWithImpl<$Res, $Val extends AssessmentQuestion>
    implements $AssessmentQuestionCopyWith<$Res> {
  _$AssessmentQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? questionText = null,
    Object? questionType = null,
    Object? showInstruction = null,
    Object? instructionText = freezed,
    Object? required = null,
    Object? allowMultiSelect = null,
    Object? hasCorrectnessGate = null,
    Object? characterLimit = freezed,
    Object? saved = null,
    Object? options = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      questionText: null == questionText
          ? _value.questionText
          : questionText // ignore: cast_nullable_to_non_nullable
              as String,
      questionType: null == questionType
          ? _value.questionType
          : questionType // ignore: cast_nullable_to_non_nullable
              as String,
      showInstruction: null == showInstruction
          ? _value.showInstruction
          : showInstruction // ignore: cast_nullable_to_non_nullable
              as bool,
      instructionText: freezed == instructionText
          ? _value.instructionText
          : instructionText // ignore: cast_nullable_to_non_nullable
              as String?,
      required: null == required
          ? _value.required
          : required // ignore: cast_nullable_to_non_nullable
              as bool,
      allowMultiSelect: null == allowMultiSelect
          ? _value.allowMultiSelect
          : allowMultiSelect // ignore: cast_nullable_to_non_nullable
              as bool,
      hasCorrectnessGate: null == hasCorrectnessGate
          ? _value.hasCorrectnessGate
          : hasCorrectnessGate // ignore: cast_nullable_to_non_nullable
              as bool,
      characterLimit: freezed == characterLimit
          ? _value.characterLimit
          : characterLimit // ignore: cast_nullable_to_non_nullable
              as int?,
      saved: null == saved
          ? _value.saved
          : saved // ignore: cast_nullable_to_non_nullable
              as SavedAnswer,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as List<AssessmentOption>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SavedAnswerCopyWith<$Res> get saved {
    return $SavedAnswerCopyWith<$Res>(_value.saved, (value) {
      return _then(_value.copyWith(saved: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AssessmentQuestionImplCopyWith<$Res>
    implements $AssessmentQuestionCopyWith<$Res> {
  factory _$$AssessmentQuestionImplCopyWith(_$AssessmentQuestionImpl value,
          $Res Function(_$AssessmentQuestionImpl) then) =
      __$$AssessmentQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      @JsonKey(name: 'question_text') String questionText,
      @JsonKey(name: 'question_type') String questionType,
      @JsonKey(name: 'show_instruction') bool showInstruction,
      @JsonKey(name: 'instruction_text') String? instructionText,
      bool required,
      @JsonKey(name: 'allow_multi_select') bool allowMultiSelect,
      @JsonKey(name: 'has_correctness_gate') bool hasCorrectnessGate,
      @JsonKey(name: 'character_limit') int? characterLimit,
      SavedAnswer saved,
      List<AssessmentOption> options});

  @override
  $SavedAnswerCopyWith<$Res> get saved;
}

/// @nodoc
class __$$AssessmentQuestionImplCopyWithImpl<$Res>
    extends _$AssessmentQuestionCopyWithImpl<$Res, _$AssessmentQuestionImpl>
    implements _$$AssessmentQuestionImplCopyWith<$Res> {
  __$$AssessmentQuestionImplCopyWithImpl(_$AssessmentQuestionImpl _value,
      $Res Function(_$AssessmentQuestionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? questionText = null,
    Object? questionType = null,
    Object? showInstruction = null,
    Object? instructionText = freezed,
    Object? required = null,
    Object? allowMultiSelect = null,
    Object? hasCorrectnessGate = null,
    Object? characterLimit = freezed,
    Object? saved = null,
    Object? options = null,
  }) {
    return _then(_$AssessmentQuestionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      questionText: null == questionText
          ? _value.questionText
          : questionText // ignore: cast_nullable_to_non_nullable
              as String,
      questionType: null == questionType
          ? _value.questionType
          : questionType // ignore: cast_nullable_to_non_nullable
              as String,
      showInstruction: null == showInstruction
          ? _value.showInstruction
          : showInstruction // ignore: cast_nullable_to_non_nullable
              as bool,
      instructionText: freezed == instructionText
          ? _value.instructionText
          : instructionText // ignore: cast_nullable_to_non_nullable
              as String?,
      required: null == required
          ? _value.required
          : required // ignore: cast_nullable_to_non_nullable
              as bool,
      allowMultiSelect: null == allowMultiSelect
          ? _value.allowMultiSelect
          : allowMultiSelect // ignore: cast_nullable_to_non_nullable
              as bool,
      hasCorrectnessGate: null == hasCorrectnessGate
          ? _value.hasCorrectnessGate
          : hasCorrectnessGate // ignore: cast_nullable_to_non_nullable
              as bool,
      characterLimit: freezed == characterLimit
          ? _value.characterLimit
          : characterLimit // ignore: cast_nullable_to_non_nullable
              as int?,
      saved: null == saved
          ? _value.saved
          : saved // ignore: cast_nullable_to_non_nullable
              as SavedAnswer,
      options: null == options
          ? _value._options
          : options // ignore: cast_nullable_to_non_nullable
              as List<AssessmentOption>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssessmentQuestionImpl implements _AssessmentQuestion {
  const _$AssessmentQuestionImpl(
      {required this.id,
      required this.title,
      @JsonKey(name: 'question_text') required this.questionText,
      @JsonKey(name: 'question_type') required this.questionType,
      @JsonKey(name: 'show_instruction') required this.showInstruction,
      @JsonKey(name: 'instruction_text') this.instructionText,
      required this.required,
      @JsonKey(name: 'allow_multi_select') required this.allowMultiSelect,
      @JsonKey(name: 'has_correctness_gate') required this.hasCorrectnessGate,
      @JsonKey(name: 'character_limit') this.characterLimit,
      required this.saved,
      required final List<AssessmentOption> options})
      : _options = options;

  factory _$AssessmentQuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssessmentQuestionImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  @JsonKey(name: 'question_text')
  final String questionText;
  @override
  @JsonKey(name: 'question_type')
  final String questionType;
  @override
  @JsonKey(name: 'show_instruction')
  final bool showInstruction;
  @override
  @JsonKey(name: 'instruction_text')
  final String? instructionText;
  @override
  final bool required;
  @override
  @JsonKey(name: 'allow_multi_select')
  final bool allowMultiSelect;
  @override
  @JsonKey(name: 'has_correctness_gate')
  final bool hasCorrectnessGate;
  @override
  @JsonKey(name: 'character_limit')
  final int? characterLimit;
  @override
  final SavedAnswer saved;
  final List<AssessmentOption> _options;
  @override
  List<AssessmentOption> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  String toString() {
    return 'AssessmentQuestion(id: $id, title: $title, questionText: $questionText, questionType: $questionType, showInstruction: $showInstruction, instructionText: $instructionText, required: $required, allowMultiSelect: $allowMultiSelect, hasCorrectnessGate: $hasCorrectnessGate, characterLimit: $characterLimit, saved: $saved, options: $options)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssessmentQuestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.questionText, questionText) ||
                other.questionText == questionText) &&
            (identical(other.questionType, questionType) ||
                other.questionType == questionType) &&
            (identical(other.showInstruction, showInstruction) ||
                other.showInstruction == showInstruction) &&
            (identical(other.instructionText, instructionText) ||
                other.instructionText == instructionText) &&
            (identical(other.required, required) ||
                other.required == required) &&
            (identical(other.allowMultiSelect, allowMultiSelect) ||
                other.allowMultiSelect == allowMultiSelect) &&
            (identical(other.hasCorrectnessGate, hasCorrectnessGate) ||
                other.hasCorrectnessGate == hasCorrectnessGate) &&
            (identical(other.characterLimit, characterLimit) ||
                other.characterLimit == characterLimit) &&
            (identical(other.saved, saved) || other.saved == saved) &&
            const DeepCollectionEquality().equals(other._options, _options));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      questionText,
      questionType,
      showInstruction,
      instructionText,
      required,
      allowMultiSelect,
      hasCorrectnessGate,
      characterLimit,
      saved,
      const DeepCollectionEquality().hash(_options));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AssessmentQuestionImplCopyWith<_$AssessmentQuestionImpl> get copyWith =>
      __$$AssessmentQuestionImplCopyWithImpl<_$AssessmentQuestionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssessmentQuestionImplToJson(
      this,
    );
  }
}

abstract class _AssessmentQuestion implements AssessmentQuestion {
  const factory _AssessmentQuestion(
      {required final int id,
      required final String title,
      @JsonKey(name: 'question_text') required final String questionText,
      @JsonKey(name: 'question_type') required final String questionType,
      @JsonKey(name: 'show_instruction') required final bool showInstruction,
      @JsonKey(name: 'instruction_text') final String? instructionText,
      required final bool required,
      @JsonKey(name: 'allow_multi_select') required final bool allowMultiSelect,
      @JsonKey(name: 'has_correctness_gate')
      required final bool hasCorrectnessGate,
      @JsonKey(name: 'character_limit') final int? characterLimit,
      required final SavedAnswer saved,
      required final List<AssessmentOption>
          options}) = _$AssessmentQuestionImpl;

  factory _AssessmentQuestion.fromJson(Map<String, dynamic> json) =
      _$AssessmentQuestionImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  @JsonKey(name: 'question_text')
  String get questionText;
  @override
  @JsonKey(name: 'question_type')
  String get questionType;
  @override
  @JsonKey(name: 'show_instruction')
  bool get showInstruction;
  @override
  @JsonKey(name: 'instruction_text')
  String? get instructionText;
  @override
  bool get required;
  @override
  @JsonKey(name: 'allow_multi_select')
  bool get allowMultiSelect;
  @override
  @JsonKey(name: 'has_correctness_gate')
  bool get hasCorrectnessGate;
  @override
  @JsonKey(name: 'character_limit')
  int? get characterLimit;
  @override
  SavedAnswer get saved;
  @override
  List<AssessmentOption> get options;
  @override
  @JsonKey(ignore: true)
  _$$AssessmentQuestionImplCopyWith<_$AssessmentQuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AssessmentProgress _$AssessmentProgressFromJson(Map<String, dynamic> json) {
  return _AssessmentProgress.fromJson(json);
}

/// @nodoc
mixin _$AssessmentProgress {
  int get current => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AssessmentProgressCopyWith<AssessmentProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssessmentProgressCopyWith<$Res> {
  factory $AssessmentProgressCopyWith(
          AssessmentProgress value, $Res Function(AssessmentProgress) then) =
      _$AssessmentProgressCopyWithImpl<$Res, AssessmentProgress>;
  @useResult
  $Res call({int current, int total});
}

/// @nodoc
class _$AssessmentProgressCopyWithImpl<$Res, $Val extends AssessmentProgress>
    implements $AssessmentProgressCopyWith<$Res> {
  _$AssessmentProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? current = null,
    Object? total = null,
  }) {
    return _then(_value.copyWith(
      current: null == current
          ? _value.current
          : current // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AssessmentProgressImplCopyWith<$Res>
    implements $AssessmentProgressCopyWith<$Res> {
  factory _$$AssessmentProgressImplCopyWith(_$AssessmentProgressImpl value,
          $Res Function(_$AssessmentProgressImpl) then) =
      __$$AssessmentProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int current, int total});
}

/// @nodoc
class __$$AssessmentProgressImplCopyWithImpl<$Res>
    extends _$AssessmentProgressCopyWithImpl<$Res, _$AssessmentProgressImpl>
    implements _$$AssessmentProgressImplCopyWith<$Res> {
  __$$AssessmentProgressImplCopyWithImpl(_$AssessmentProgressImpl _value,
      $Res Function(_$AssessmentProgressImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? current = null,
    Object? total = null,
  }) {
    return _then(_$AssessmentProgressImpl(
      current: null == current
          ? _value.current
          : current // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssessmentProgressImpl implements _AssessmentProgress {
  const _$AssessmentProgressImpl({required this.current, required this.total});

  factory _$AssessmentProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssessmentProgressImplFromJson(json);

  @override
  final int current;
  @override
  final int total;

  @override
  String toString() {
    return 'AssessmentProgress(current: $current, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssessmentProgressImpl &&
            (identical(other.current, current) || other.current == current) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, current, total);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AssessmentProgressImplCopyWith<_$AssessmentProgressImpl> get copyWith =>
      __$$AssessmentProgressImplCopyWithImpl<_$AssessmentProgressImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssessmentProgressImplToJson(
      this,
    );
  }
}

abstract class _AssessmentProgress implements AssessmentProgress {
  const factory _AssessmentProgress(
      {required final int current,
      required final int total}) = _$AssessmentProgressImpl;

  factory _AssessmentProgress.fromJson(Map<String, dynamic> json) =
      _$AssessmentProgressImpl.fromJson;

  @override
  int get current;
  @override
  int get total;
  @override
  @JsonKey(ignore: true)
  _$$AssessmentProgressImplCopyWith<_$AssessmentProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AssessmentAttemptInfo _$AssessmentAttemptInfoFromJson(
    Map<String, dynamic> json) {
  return _AssessmentAttemptInfo.fromJson(json);
}

/// @nodoc
mixin _$AssessmentAttemptInfo {
  int get id => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  String? get expiresAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AssessmentAttemptInfoCopyWith<AssessmentAttemptInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssessmentAttemptInfoCopyWith<$Res> {
  factory $AssessmentAttemptInfoCopyWith(AssessmentAttemptInfo value,
          $Res Function(AssessmentAttemptInfo) then) =
      _$AssessmentAttemptInfoCopyWithImpl<$Res, AssessmentAttemptInfo>;
  @useResult
  $Res call(
      {int id, String status, @JsonKey(name: 'expires_at') String? expiresAt});
}

/// @nodoc
class _$AssessmentAttemptInfoCopyWithImpl<$Res,
        $Val extends AssessmentAttemptInfo>
    implements $AssessmentAttemptInfoCopyWith<$Res> {
  _$AssessmentAttemptInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? expiresAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AssessmentAttemptInfoImplCopyWith<$Res>
    implements $AssessmentAttemptInfoCopyWith<$Res> {
  factory _$$AssessmentAttemptInfoImplCopyWith(
          _$AssessmentAttemptInfoImpl value,
          $Res Function(_$AssessmentAttemptInfoImpl) then) =
      __$$AssessmentAttemptInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id, String status, @JsonKey(name: 'expires_at') String? expiresAt});
}

/// @nodoc
class __$$AssessmentAttemptInfoImplCopyWithImpl<$Res>
    extends _$AssessmentAttemptInfoCopyWithImpl<$Res,
        _$AssessmentAttemptInfoImpl>
    implements _$$AssessmentAttemptInfoImplCopyWith<$Res> {
  __$$AssessmentAttemptInfoImplCopyWithImpl(_$AssessmentAttemptInfoImpl _value,
      $Res Function(_$AssessmentAttemptInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? expiresAt = freezed,
  }) {
    return _then(_$AssessmentAttemptInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssessmentAttemptInfoImpl implements _AssessmentAttemptInfo {
  const _$AssessmentAttemptInfoImpl(
      {required this.id,
      required this.status,
      @JsonKey(name: 'expires_at') this.expiresAt});

  factory _$AssessmentAttemptInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssessmentAttemptInfoImplFromJson(json);

  @override
  final int id;
  @override
  final String status;
  @override
  @JsonKey(name: 'expires_at')
  final String? expiresAt;

  @override
  String toString() {
    return 'AssessmentAttemptInfo(id: $id, status: $status, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssessmentAttemptInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, status, expiresAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AssessmentAttemptInfoImplCopyWith<_$AssessmentAttemptInfoImpl>
      get copyWith => __$$AssessmentAttemptInfoImplCopyWithImpl<
          _$AssessmentAttemptInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssessmentAttemptInfoImplToJson(
      this,
    );
  }
}

abstract class _AssessmentAttemptInfo implements AssessmentAttemptInfo {
  const factory _AssessmentAttemptInfo(
          {required final int id,
          required final String status,
          @JsonKey(name: 'expires_at') final String? expiresAt}) =
      _$AssessmentAttemptInfoImpl;

  factory _AssessmentAttemptInfo.fromJson(Map<String, dynamic> json) =
      _$AssessmentAttemptInfoImpl.fromJson;

  @override
  int get id;
  @override
  String get status;
  @override
  @JsonKey(name: 'expires_at')
  String? get expiresAt;
  @override
  @JsonKey(ignore: true)
  _$$AssessmentAttemptInfoImplCopyWith<_$AssessmentAttemptInfoImpl>
      get copyWith => throw _privateConstructorUsedError;
}

AssessmentPlayInfo _$AssessmentPlayInfoFromJson(Map<String, dynamic> json) {
  return _AssessmentPlayInfo.fromJson(json);
}

/// @nodoc
mixin _$AssessmentPlayInfo {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'allow_back_navigation')
  bool get allowBackNavigation => throw _privateConstructorUsedError;
  @JsonKey(name: 'show_progress_bar')
  bool get showProgressBar => throw _privateConstructorUsedError;
  AssessmentProgress get progress => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AssessmentPlayInfoCopyWith<AssessmentPlayInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssessmentPlayInfoCopyWith<$Res> {
  factory $AssessmentPlayInfoCopyWith(
          AssessmentPlayInfo value, $Res Function(AssessmentPlayInfo) then) =
      _$AssessmentPlayInfoCopyWithImpl<$Res, AssessmentPlayInfo>;
  @useResult
  $Res call(
      {int id,
      String title,
      @JsonKey(name: 'allow_back_navigation') bool allowBackNavigation,
      @JsonKey(name: 'show_progress_bar') bool showProgressBar,
      AssessmentProgress progress});

  $AssessmentProgressCopyWith<$Res> get progress;
}

/// @nodoc
class _$AssessmentPlayInfoCopyWithImpl<$Res, $Val extends AssessmentPlayInfo>
    implements $AssessmentPlayInfoCopyWith<$Res> {
  _$AssessmentPlayInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? allowBackNavigation = null,
    Object? showProgressBar = null,
    Object? progress = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      allowBackNavigation: null == allowBackNavigation
          ? _value.allowBackNavigation
          : allowBackNavigation // ignore: cast_nullable_to_non_nullable
              as bool,
      showProgressBar: null == showProgressBar
          ? _value.showProgressBar
          : showProgressBar // ignore: cast_nullable_to_non_nullable
              as bool,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as AssessmentProgress,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AssessmentProgressCopyWith<$Res> get progress {
    return $AssessmentProgressCopyWith<$Res>(_value.progress, (value) {
      return _then(_value.copyWith(progress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AssessmentPlayInfoImplCopyWith<$Res>
    implements $AssessmentPlayInfoCopyWith<$Res> {
  factory _$$AssessmentPlayInfoImplCopyWith(_$AssessmentPlayInfoImpl value,
          $Res Function(_$AssessmentPlayInfoImpl) then) =
      __$$AssessmentPlayInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      @JsonKey(name: 'allow_back_navigation') bool allowBackNavigation,
      @JsonKey(name: 'show_progress_bar') bool showProgressBar,
      AssessmentProgress progress});

  @override
  $AssessmentProgressCopyWith<$Res> get progress;
}

/// @nodoc
class __$$AssessmentPlayInfoImplCopyWithImpl<$Res>
    extends _$AssessmentPlayInfoCopyWithImpl<$Res, _$AssessmentPlayInfoImpl>
    implements _$$AssessmentPlayInfoImplCopyWith<$Res> {
  __$$AssessmentPlayInfoImplCopyWithImpl(_$AssessmentPlayInfoImpl _value,
      $Res Function(_$AssessmentPlayInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? allowBackNavigation = null,
    Object? showProgressBar = null,
    Object? progress = null,
  }) {
    return _then(_$AssessmentPlayInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      allowBackNavigation: null == allowBackNavigation
          ? _value.allowBackNavigation
          : allowBackNavigation // ignore: cast_nullable_to_non_nullable
              as bool,
      showProgressBar: null == showProgressBar
          ? _value.showProgressBar
          : showProgressBar // ignore: cast_nullable_to_non_nullable
              as bool,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as AssessmentProgress,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssessmentPlayInfoImpl implements _AssessmentPlayInfo {
  const _$AssessmentPlayInfoImpl(
      {required this.id,
      required this.title,
      @JsonKey(name: 'allow_back_navigation') required this.allowBackNavigation,
      @JsonKey(name: 'show_progress_bar') required this.showProgressBar,
      required this.progress});

  factory _$AssessmentPlayInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssessmentPlayInfoImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  @JsonKey(name: 'allow_back_navigation')
  final bool allowBackNavigation;
  @override
  @JsonKey(name: 'show_progress_bar')
  final bool showProgressBar;
  @override
  final AssessmentProgress progress;

  @override
  String toString() {
    return 'AssessmentPlayInfo(id: $id, title: $title, allowBackNavigation: $allowBackNavigation, showProgressBar: $showProgressBar, progress: $progress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssessmentPlayInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.allowBackNavigation, allowBackNavigation) ||
                other.allowBackNavigation == allowBackNavigation) &&
            (identical(other.showProgressBar, showProgressBar) ||
                other.showProgressBar == showProgressBar) &&
            (identical(other.progress, progress) ||
                other.progress == progress));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, title, allowBackNavigation, showProgressBar, progress);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AssessmentPlayInfoImplCopyWith<_$AssessmentPlayInfoImpl> get copyWith =>
      __$$AssessmentPlayInfoImplCopyWithImpl<_$AssessmentPlayInfoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssessmentPlayInfoImplToJson(
      this,
    );
  }
}

abstract class _AssessmentPlayInfo implements AssessmentPlayInfo {
  const factory _AssessmentPlayInfo(
      {required final int id,
      required final String title,
      @JsonKey(name: 'allow_back_navigation')
      required final bool allowBackNavigation,
      @JsonKey(name: 'show_progress_bar') required final bool showProgressBar,
      required final AssessmentProgress progress}) = _$AssessmentPlayInfoImpl;

  factory _AssessmentPlayInfo.fromJson(Map<String, dynamic> json) =
      _$AssessmentPlayInfoImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  @JsonKey(name: 'allow_back_navigation')
  bool get allowBackNavigation;
  @override
  @JsonKey(name: 'show_progress_bar')
  bool get showProgressBar;
  @override
  AssessmentProgress get progress;
  @override
  @JsonKey(ignore: true)
  _$$AssessmentPlayInfoImplCopyWith<_$AssessmentPlayInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AssessmentAttemptData _$AssessmentAttemptDataFromJson(
    Map<String, dynamic> json) {
  return _AssessmentAttemptData.fromJson(json);
}

/// @nodoc
mixin _$AssessmentAttemptData {
  String get mode => throw _privateConstructorUsedError;
  AssessmentPlayInfo get assessment => throw _privateConstructorUsedError;
  AssessmentAttemptInfo get attempt => throw _privateConstructorUsedError;
  AssessmentQuestion get question => throw _privateConstructorUsedError;
  @JsonKey(name: 'can_go_back')
  bool get canGoBack => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_last_question')
  bool get isLastQuestion => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AssessmentAttemptDataCopyWith<AssessmentAttemptData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssessmentAttemptDataCopyWith<$Res> {
  factory $AssessmentAttemptDataCopyWith(AssessmentAttemptData value,
          $Res Function(AssessmentAttemptData) then) =
      _$AssessmentAttemptDataCopyWithImpl<$Res, AssessmentAttemptData>;
  @useResult
  $Res call(
      {String mode,
      AssessmentPlayInfo assessment,
      AssessmentAttemptInfo attempt,
      AssessmentQuestion question,
      @JsonKey(name: 'can_go_back') bool canGoBack,
      @JsonKey(name: 'is_last_question') bool isLastQuestion});

  $AssessmentPlayInfoCopyWith<$Res> get assessment;
  $AssessmentAttemptInfoCopyWith<$Res> get attempt;
  $AssessmentQuestionCopyWith<$Res> get question;
}

/// @nodoc
class _$AssessmentAttemptDataCopyWithImpl<$Res,
        $Val extends AssessmentAttemptData>
    implements $AssessmentAttemptDataCopyWith<$Res> {
  _$AssessmentAttemptDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? assessment = null,
    Object? attempt = null,
    Object? question = null,
    Object? canGoBack = null,
    Object? isLastQuestion = null,
  }) {
    return _then(_value.copyWith(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String,
      assessment: null == assessment
          ? _value.assessment
          : assessment // ignore: cast_nullable_to_non_nullable
              as AssessmentPlayInfo,
      attempt: null == attempt
          ? _value.attempt
          : attempt // ignore: cast_nullable_to_non_nullable
              as AssessmentAttemptInfo,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as AssessmentQuestion,
      canGoBack: null == canGoBack
          ? _value.canGoBack
          : canGoBack // ignore: cast_nullable_to_non_nullable
              as bool,
      isLastQuestion: null == isLastQuestion
          ? _value.isLastQuestion
          : isLastQuestion // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AssessmentPlayInfoCopyWith<$Res> get assessment {
    return $AssessmentPlayInfoCopyWith<$Res>(_value.assessment, (value) {
      return _then(_value.copyWith(assessment: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AssessmentAttemptInfoCopyWith<$Res> get attempt {
    return $AssessmentAttemptInfoCopyWith<$Res>(_value.attempt, (value) {
      return _then(_value.copyWith(attempt: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AssessmentQuestionCopyWith<$Res> get question {
    return $AssessmentQuestionCopyWith<$Res>(_value.question, (value) {
      return _then(_value.copyWith(question: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AssessmentAttemptDataImplCopyWith<$Res>
    implements $AssessmentAttemptDataCopyWith<$Res> {
  factory _$$AssessmentAttemptDataImplCopyWith(
          _$AssessmentAttemptDataImpl value,
          $Res Function(_$AssessmentAttemptDataImpl) then) =
      __$$AssessmentAttemptDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String mode,
      AssessmentPlayInfo assessment,
      AssessmentAttemptInfo attempt,
      AssessmentQuestion question,
      @JsonKey(name: 'can_go_back') bool canGoBack,
      @JsonKey(name: 'is_last_question') bool isLastQuestion});

  @override
  $AssessmentPlayInfoCopyWith<$Res> get assessment;
  @override
  $AssessmentAttemptInfoCopyWith<$Res> get attempt;
  @override
  $AssessmentQuestionCopyWith<$Res> get question;
}

/// @nodoc
class __$$AssessmentAttemptDataImplCopyWithImpl<$Res>
    extends _$AssessmentAttemptDataCopyWithImpl<$Res,
        _$AssessmentAttemptDataImpl>
    implements _$$AssessmentAttemptDataImplCopyWith<$Res> {
  __$$AssessmentAttemptDataImplCopyWithImpl(_$AssessmentAttemptDataImpl _value,
      $Res Function(_$AssessmentAttemptDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? assessment = null,
    Object? attempt = null,
    Object? question = null,
    Object? canGoBack = null,
    Object? isLastQuestion = null,
  }) {
    return _then(_$AssessmentAttemptDataImpl(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String,
      assessment: null == assessment
          ? _value.assessment
          : assessment // ignore: cast_nullable_to_non_nullable
              as AssessmentPlayInfo,
      attempt: null == attempt
          ? _value.attempt
          : attempt // ignore: cast_nullable_to_non_nullable
              as AssessmentAttemptInfo,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as AssessmentQuestion,
      canGoBack: null == canGoBack
          ? _value.canGoBack
          : canGoBack // ignore: cast_nullable_to_non_nullable
              as bool,
      isLastQuestion: null == isLastQuestion
          ? _value.isLastQuestion
          : isLastQuestion // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssessmentAttemptDataImpl implements _AssessmentAttemptData {
  const _$AssessmentAttemptDataImpl(
      {required this.mode,
      required this.assessment,
      required this.attempt,
      required this.question,
      @JsonKey(name: 'can_go_back') required this.canGoBack,
      @JsonKey(name: 'is_last_question') required this.isLastQuestion});

  factory _$AssessmentAttemptDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssessmentAttemptDataImplFromJson(json);

  @override
  final String mode;
  @override
  final AssessmentPlayInfo assessment;
  @override
  final AssessmentAttemptInfo attempt;
  @override
  final AssessmentQuestion question;
  @override
  @JsonKey(name: 'can_go_back')
  final bool canGoBack;
  @override
  @JsonKey(name: 'is_last_question')
  final bool isLastQuestion;

  @override
  String toString() {
    return 'AssessmentAttemptData(mode: $mode, assessment: $assessment, attempt: $attempt, question: $question, canGoBack: $canGoBack, isLastQuestion: $isLastQuestion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssessmentAttemptDataImpl &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.assessment, assessment) ||
                other.assessment == assessment) &&
            (identical(other.attempt, attempt) || other.attempt == attempt) &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.canGoBack, canGoBack) ||
                other.canGoBack == canGoBack) &&
            (identical(other.isLastQuestion, isLastQuestion) ||
                other.isLastQuestion == isLastQuestion));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, mode, assessment, attempt,
      question, canGoBack, isLastQuestion);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AssessmentAttemptDataImplCopyWith<_$AssessmentAttemptDataImpl>
      get copyWith => __$$AssessmentAttemptDataImplCopyWithImpl<
          _$AssessmentAttemptDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssessmentAttemptDataImplToJson(
      this,
    );
  }
}

abstract class _AssessmentAttemptData implements AssessmentAttemptData {
  const factory _AssessmentAttemptData(
      {required final String mode,
      required final AssessmentPlayInfo assessment,
      required final AssessmentAttemptInfo attempt,
      required final AssessmentQuestion question,
      @JsonKey(name: 'can_go_back') required final bool canGoBack,
      @JsonKey(name: 'is_last_question')
      required final bool isLastQuestion}) = _$AssessmentAttemptDataImpl;

  factory _AssessmentAttemptData.fromJson(Map<String, dynamic> json) =
      _$AssessmentAttemptDataImpl.fromJson;

  @override
  String get mode;
  @override
  AssessmentPlayInfo get assessment;
  @override
  AssessmentAttemptInfo get attempt;
  @override
  AssessmentQuestion get question;
  @override
  @JsonKey(name: 'can_go_back')
  bool get canGoBack;
  @override
  @JsonKey(name: 'is_last_question')
  bool get isLastQuestion;
  @override
  @JsonKey(ignore: true)
  _$$AssessmentAttemptDataImplCopyWith<_$AssessmentAttemptDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

AssessmentResultData _$AssessmentResultDataFromJson(Map<String, dynamic> json) {
  return _AssessmentResultData.fromJson(json);
}

/// @nodoc
mixin _$AssessmentResultData {
  String get mode => throw _privateConstructorUsedError;
  @JsonKey(name: 'attempt_id')
  int get attemptId => throw _privateConstructorUsedError;
  @JsonKey(name: 'score_percentage')
  double? get scorePercentage => throw _privateConstructorUsedError;
  @JsonKey(name: 'correct_answers')
  int? get correctAnswers => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_questions')
  int? get totalQuestions => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AssessmentResultDataCopyWith<AssessmentResultData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssessmentResultDataCopyWith<$Res> {
  factory $AssessmentResultDataCopyWith(AssessmentResultData value,
          $Res Function(AssessmentResultData) then) =
      _$AssessmentResultDataCopyWithImpl<$Res, AssessmentResultData>;
  @useResult
  $Res call({
    String mode,
    @JsonKey(name: 'attempt_id') int attemptId,
    @JsonKey(name: 'score_percentage') double? scorePercentage,
    @JsonKey(name: 'correct_answers') int? correctAnswers,
    @JsonKey(name: 'total_questions') int? totalQuestions,
    String? status
  });
}

/// @nodoc
class _$AssessmentResultDataCopyWithImpl<$Res,
        $Val extends AssessmentResultData>
    implements $AssessmentResultDataCopyWith<$Res> {
  _$AssessmentResultDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? attemptId = null,
    Object? scorePercentage = freezed,
    Object? correctAnswers = freezed,
    Object? totalQuestions = freezed,
    Object? status = freezed,
  }) {
    return _then(_value.copyWith(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String,
      attemptId: null == attemptId
          ? _value.attemptId
          : attemptId // ignore: cast_nullable_to_non_nullable
              as int,
      scorePercentage: freezed == scorePercentage
          ? _value.scorePercentage
          : scorePercentage // ignore: cast_nullable_to_non_nullable
              as double?,
      correctAnswers: freezed == correctAnswers
          ? _value.correctAnswers
          : correctAnswers // ignore: cast_nullable_to_non_nullable
              as int?,
      totalQuestions: freezed == totalQuestions
          ? _value.totalQuestions
          : totalQuestions // ignore: cast_nullable_to_non_nullable
              as int?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AssessmentResultDataImplCopyWith<$Res>
    implements $AssessmentResultDataCopyWith<$Res> {
  factory _$$AssessmentResultDataImplCopyWith(_$AssessmentResultDataImpl value,
          $Res Function(_$AssessmentResultDataImpl) then) =
      __$$AssessmentResultDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String mode,
    @JsonKey(name: 'attempt_id') int attemptId,
    @JsonKey(name: 'score_percentage') double? scorePercentage,
    @JsonKey(name: 'correct_answers') int? correctAnswers,
    @JsonKey(name: 'total_questions') int? totalQuestions,
    String? status
  });
}

/// @nodoc
class __$$AssessmentResultDataImplCopyWithImpl<$Res>
    extends _$AssessmentResultDataCopyWithImpl<$Res, _$AssessmentResultDataImpl>
    implements _$$AssessmentResultDataImplCopyWith<$Res> {
  __$$AssessmentResultDataImplCopyWithImpl(_$AssessmentResultDataImpl _value,
      $Res Function(_$AssessmentResultDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? attemptId = null,
    Object? scorePercentage = freezed,
    Object? correctAnswers = freezed,
    Object? totalQuestions = freezed,
    Object? status = freezed,
  }) {
    return _then(_$AssessmentResultDataImpl(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String,
      attemptId: null == attemptId
          ? _value.attemptId
          : attemptId // ignore: cast_nullable_to_non_nullable
              as int,
      scorePercentage: freezed == scorePercentage
          ? _value.scorePercentage
          : scorePercentage // ignore: cast_nullable_to_non_nullable
              as double?,
      correctAnswers: freezed == correctAnswers
          ? _value.correctAnswers
          : correctAnswers // ignore: cast_nullable_to_non_nullable
              as int?,
      totalQuestions: freezed == totalQuestions
          ? _value.totalQuestions
          : totalQuestions // ignore: cast_nullable_to_non_nullable
              as int?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssessmentResultDataImpl implements _AssessmentResultData {
  const _$AssessmentResultDataImpl(
      {required this.mode,
      @JsonKey(name: 'attempt_id') required this.attemptId,
      @JsonKey(name: 'score_percentage') this.scorePercentage,
      @JsonKey(name: 'correct_answers') this.correctAnswers,
      @JsonKey(name: 'total_questions') this.totalQuestions,
      this.status});

  factory _$AssessmentResultDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssessmentResultDataImplFromJson(json);

  @override
  final String mode;
  @override
  @JsonKey(name: 'attempt_id')
  final int attemptId;
  @override
  @JsonKey(name: 'score_percentage')
  final double? scorePercentage;
  @override
  @JsonKey(name: 'correct_answers')
  final int? correctAnswers;
  @override
  @JsonKey(name: 'total_questions')
  final int? totalQuestions;
  @override
  final String? status;

  @override
  String toString() {
    return 'AssessmentResultData(mode: $mode, attemptId: $attemptId, scorePercentage: $scorePercentage, correctAnswers: $correctAnswers, totalQuestions: $totalQuestions, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssessmentResultDataImpl &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.attemptId, attemptId) ||
                other.attemptId == attemptId) &&
            (identical(other.scorePercentage, scorePercentage) ||
                other.scorePercentage == scorePercentage) &&
            (identical(other.correctAnswers, correctAnswers) ||
                other.correctAnswers == correctAnswers) &&
            (identical(other.totalQuestions, totalQuestions) ||
                other.totalQuestions == totalQuestions) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, mode, attemptId,
      scorePercentage, correctAnswers, totalQuestions, status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AssessmentResultDataImplCopyWith<_$AssessmentResultDataImpl>
      get copyWith =>
          __$$AssessmentResultDataImplCopyWithImpl<_$AssessmentResultDataImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssessmentResultDataImplToJson(
      this,
    );
  }
}

abstract class _AssessmentResultData implements AssessmentResultData {
  const factory _AssessmentResultData(
          {required final String mode,
          @JsonKey(name: 'attempt_id') required final int attemptId,
          @JsonKey(name: 'score_percentage') final double? scorePercentage,
          @JsonKey(name: 'correct_answers') final int? correctAnswers,
          @JsonKey(name: 'total_questions') final int? totalQuestions,
          final String? status}) =
      _$AssessmentResultDataImpl;

  factory _AssessmentResultData.fromJson(Map<String, dynamic> json) =
      _$AssessmentResultDataImpl.fromJson;

  @override
  String get mode;
  @override
  @JsonKey(name: 'attempt_id')
  int get attemptId;
  @override
  @JsonKey(name: 'score_percentage')
  double? get scorePercentage;
  @override
  @JsonKey(name: 'correct_answers')
  int? get correctAnswers;
  @override
  @JsonKey(name: 'total_questions')
  int? get totalQuestions;
  @override
  String? get status;
  @override
  @JsonKey(ignore: true)
  _$$AssessmentResultDataImplCopyWith<_$AssessmentResultDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}
