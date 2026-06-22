// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DashboardStudent _$DashboardStudentFromJson(Map<String, dynamic> json) {
  return _DashboardStudent.fromJson(json);
}

/// @nodoc
mixin _$DashboardStudent {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'access_tier')
  DashboardTier get accessTier => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DashboardStudentCopyWith<DashboardStudent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardStudentCopyWith<$Res> {
  factory $DashboardStudentCopyWith(
          DashboardStudent value, $Res Function(DashboardStudent) then) =
      _$DashboardStudentCopyWithImpl<$Res, DashboardStudent>;
  @useResult
  $Res call(
      {int id,
      String name,
      String email,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'access_tier') DashboardTier accessTier});

  $DashboardTierCopyWith<$Res> get accessTier;
}

/// @nodoc
class _$DashboardStudentCopyWithImpl<$Res, $Val extends DashboardStudent>
    implements $DashboardStudentCopyWith<$Res> {
  _$DashboardStudentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? firstName = null,
    Object? accessTier = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      accessTier: null == accessTier
          ? _value.accessTier
          : accessTier // ignore: cast_nullable_to_non_nullable
              as DashboardTier,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $DashboardTierCopyWith<$Res> get accessTier {
    return $DashboardTierCopyWith<$Res>(_value.accessTier, (value) {
      return _then(_value.copyWith(accessTier: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DashboardStudentImplCopyWith<$Res>
    implements $DashboardStudentCopyWith<$Res> {
  factory _$$DashboardStudentImplCopyWith(_$DashboardStudentImpl value,
          $Res Function(_$DashboardStudentImpl) then) =
      __$$DashboardStudentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String email,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'access_tier') DashboardTier accessTier});

  @override
  $DashboardTierCopyWith<$Res> get accessTier;
}

/// @nodoc
class __$$DashboardStudentImplCopyWithImpl<$Res>
    extends _$DashboardStudentCopyWithImpl<$Res, _$DashboardStudentImpl>
    implements _$$DashboardStudentImplCopyWith<$Res> {
  __$$DashboardStudentImplCopyWithImpl(_$DashboardStudentImpl _value,
      $Res Function(_$DashboardStudentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? firstName = null,
    Object? accessTier = null,
  }) {
    return _then(_$DashboardStudentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      accessTier: null == accessTier
          ? _value.accessTier
          : accessTier // ignore: cast_nullable_to_non_nullable
              as DashboardTier,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardStudentImpl implements _DashboardStudent {
  const _$DashboardStudentImpl(
      {required this.id,
      required this.name,
      required this.email,
      @JsonKey(name: 'first_name') required this.firstName,
      @JsonKey(name: 'access_tier') required this.accessTier});

  factory _$DashboardStudentImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardStudentImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String email;
  @override
  @JsonKey(name: 'first_name')
  final String firstName;
  @override
  @JsonKey(name: 'access_tier')
  final DashboardTier accessTier;

  @override
  String toString() {
    return 'DashboardStudent(id: $id, name: $name, email: $email, firstName: $firstName, accessTier: $accessTier)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardStudentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.accessTier, accessTier) ||
                other.accessTier == accessTier));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, email, firstName, accessTier);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardStudentImplCopyWith<_$DashboardStudentImpl> get copyWith =>
      __$$DashboardStudentImplCopyWithImpl<_$DashboardStudentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardStudentImplToJson(
      this,
    );
  }
}

abstract class _DashboardStudent implements DashboardStudent {
  const factory _DashboardStudent(
      {required final int id,
      required final String name,
      required final String email,
      @JsonKey(name: 'first_name') required final String firstName,
      @JsonKey(name: 'access_tier')
      required final DashboardTier accessTier}) = _$DashboardStudentImpl;

  factory _DashboardStudent.fromJson(Map<String, dynamic> json) =
      _$DashboardStudentImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get email;
  @override
  @JsonKey(name: 'first_name')
  String get firstName;
  @override
  @JsonKey(name: 'access_tier')
  DashboardTier get accessTier;
  @override
  @JsonKey(ignore: true)
  _$$DashboardStudentImplCopyWith<_$DashboardStudentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DashboardTier _$DashboardTierFromJson(Map<String, dynamic> json) {
  return _DashboardTier.fromJson(json);
}

/// @nodoc
mixin _$DashboardTier {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DashboardTierCopyWith<DashboardTier> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardTierCopyWith<$Res> {
  factory $DashboardTierCopyWith(
          DashboardTier value, $Res Function(DashboardTier) then) =
      _$DashboardTierCopyWithImpl<$Res, DashboardTier>;
  @useResult
  $Res call({int id, String name, String slug});
}

/// @nodoc
class _$DashboardTierCopyWithImpl<$Res, $Val extends DashboardTier>
    implements $DashboardTierCopyWith<$Res> {
  _$DashboardTierCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? slug = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DashboardTierImplCopyWith<$Res>
    implements $DashboardTierCopyWith<$Res> {
  factory _$$DashboardTierImplCopyWith(
          _$DashboardTierImpl value, $Res Function(_$DashboardTierImpl) then) =
      __$$DashboardTierImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, String slug});
}

/// @nodoc
class __$$DashboardTierImplCopyWithImpl<$Res>
    extends _$DashboardTierCopyWithImpl<$Res, _$DashboardTierImpl>
    implements _$$DashboardTierImplCopyWith<$Res> {
  __$$DashboardTierImplCopyWithImpl(
      _$DashboardTierImpl _value, $Res Function(_$DashboardTierImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? slug = null,
  }) {
    return _then(_$DashboardTierImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardTierImpl implements _DashboardTier {
  const _$DashboardTierImpl(
      {required this.id, required this.name, required this.slug});

  factory _$DashboardTierImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardTierImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String slug;

  @override
  String toString() {
    return 'DashboardTier(id: $id, name: $name, slug: $slug)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardTierImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.slug, slug) || other.slug == slug));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, slug);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardTierImplCopyWith<_$DashboardTierImpl> get copyWith =>
      __$$DashboardTierImplCopyWithImpl<_$DashboardTierImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardTierImplToJson(
      this,
    );
  }
}

abstract class _DashboardTier implements DashboardTier {
  const factory _DashboardTier(
      {required final int id,
      required final String name,
      required final String slug}) = _$DashboardTierImpl;

  factory _DashboardTier.fromJson(Map<String, dynamic> json) =
      _$DashboardTierImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get slug;
  @override
  @JsonKey(ignore: true)
  _$$DashboardTierImplCopyWith<_$DashboardTierImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ContinueLearningSection _$ContinueLearningSectionFromJson(
    Map<String, dynamic> json) {
  return _ContinueLearningSection.fromJson(json);
}

/// @nodoc
mixin _$ContinueLearningSection {
  String get state => throw _privateConstructorUsedError;
  String get eyebrow => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'progress_percentage')
  int get progressPercentage => throw _privateConstructorUsedError;
  @JsonKey(name: 'cta_label')
  String get ctaLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  DashboardLesson get lesson => throw _privateConstructorUsedError;
  DashboardModule get module => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ContinueLearningSectionCopyWith<ContinueLearningSection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContinueLearningSectionCopyWith<$Res> {
  factory $ContinueLearningSectionCopyWith(ContinueLearningSection value,
          $Res Function(ContinueLearningSection) then) =
      _$ContinueLearningSectionCopyWithImpl<$Res, ContinueLearningSection>;
  @useResult
  $Res call(
      {String state,
      String eyebrow,
      String title,
      String description,
      @JsonKey(name: 'progress_percentage') int progressPercentage,
      @JsonKey(name: 'cta_label') String ctaLabel,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
      DashboardLesson lesson,
      DashboardModule module,
      String status});

  $DashboardLessonCopyWith<$Res> get lesson;
  $DashboardModuleCopyWith<$Res> get module;
}

/// @nodoc
class _$ContinueLearningSectionCopyWithImpl<$Res,
        $Val extends ContinueLearningSection>
    implements $ContinueLearningSectionCopyWith<$Res> {
  _$ContinueLearningSectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? state = null,
    Object? eyebrow = null,
    Object? title = null,
    Object? description = null,
    Object? progressPercentage = null,
    Object? ctaLabel = null,
    Object? thumbnailUrl = freezed,
    Object? lesson = null,
    Object? module = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      eyebrow: null == eyebrow
          ? _value.eyebrow
          : eyebrow // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      progressPercentage: null == progressPercentage
          ? _value.progressPercentage
          : progressPercentage // ignore: cast_nullable_to_non_nullable
              as int,
      ctaLabel: null == ctaLabel
          ? _value.ctaLabel
          : ctaLabel // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      lesson: null == lesson
          ? _value.lesson
          : lesson // ignore: cast_nullable_to_non_nullable
              as DashboardLesson,
      module: null == module
          ? _value.module
          : module // ignore: cast_nullable_to_non_nullable
              as DashboardModule,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $DashboardLessonCopyWith<$Res> get lesson {
    return $DashboardLessonCopyWith<$Res>(_value.lesson, (value) {
      return _then(_value.copyWith(lesson: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $DashboardModuleCopyWith<$Res> get module {
    return $DashboardModuleCopyWith<$Res>(_value.module, (value) {
      return _then(_value.copyWith(module: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ContinueLearningSectionImplCopyWith<$Res>
    implements $ContinueLearningSectionCopyWith<$Res> {
  factory _$$ContinueLearningSectionImplCopyWith(
          _$ContinueLearningSectionImpl value,
          $Res Function(_$ContinueLearningSectionImpl) then) =
      __$$ContinueLearningSectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String state,
      String eyebrow,
      String title,
      String description,
      @JsonKey(name: 'progress_percentage') int progressPercentage,
      @JsonKey(name: 'cta_label') String ctaLabel,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
      DashboardLesson lesson,
      DashboardModule module,
      String status});

  @override
  $DashboardLessonCopyWith<$Res> get lesson;
  @override
  $DashboardModuleCopyWith<$Res> get module;
}

/// @nodoc
class __$$ContinueLearningSectionImplCopyWithImpl<$Res>
    extends _$ContinueLearningSectionCopyWithImpl<$Res,
        _$ContinueLearningSectionImpl>
    implements _$$ContinueLearningSectionImplCopyWith<$Res> {
  __$$ContinueLearningSectionImplCopyWithImpl(
      _$ContinueLearningSectionImpl _value,
      $Res Function(_$ContinueLearningSectionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? state = null,
    Object? eyebrow = null,
    Object? title = null,
    Object? description = null,
    Object? progressPercentage = null,
    Object? ctaLabel = null,
    Object? thumbnailUrl = freezed,
    Object? lesson = null,
    Object? module = null,
    Object? status = null,
  }) {
    return _then(_$ContinueLearningSectionImpl(
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      eyebrow: null == eyebrow
          ? _value.eyebrow
          : eyebrow // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      progressPercentage: null == progressPercentage
          ? _value.progressPercentage
          : progressPercentage // ignore: cast_nullable_to_non_nullable
              as int,
      ctaLabel: null == ctaLabel
          ? _value.ctaLabel
          : ctaLabel // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      lesson: null == lesson
          ? _value.lesson
          : lesson // ignore: cast_nullable_to_non_nullable
              as DashboardLesson,
      module: null == module
          ? _value.module
          : module // ignore: cast_nullable_to_non_nullable
              as DashboardModule,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ContinueLearningSectionImpl implements _ContinueLearningSection {
  const _$ContinueLearningSectionImpl(
      {required this.state,
      required this.eyebrow,
      required this.title,
      required this.description,
      @JsonKey(name: 'progress_percentage') required this.progressPercentage,
      @JsonKey(name: 'cta_label') required this.ctaLabel,
      @JsonKey(name: 'thumbnail_url') this.thumbnailUrl,
      required this.lesson,
      required this.module,
      required this.status});

  factory _$ContinueLearningSectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContinueLearningSectionImplFromJson(json);

  @override
  final String state;
  @override
  final String eyebrow;
  @override
  final String title;
  @override
  final String description;
  @override
  @JsonKey(name: 'progress_percentage')
  final int progressPercentage;
  @override
  @JsonKey(name: 'cta_label')
  final String ctaLabel;
  @override
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @override
  final DashboardLesson lesson;
  @override
  final DashboardModule module;
  @override
  final String status;

  @override
  String toString() {
    return 'ContinueLearningSection(state: $state, eyebrow: $eyebrow, title: $title, description: $description, progressPercentage: $progressPercentage, ctaLabel: $ctaLabel, thumbnailUrl: $thumbnailUrl, lesson: $lesson, module: $module, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContinueLearningSectionImpl &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.eyebrow, eyebrow) || other.eyebrow == eyebrow) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.progressPercentage, progressPercentage) ||
                other.progressPercentage == progressPercentage) &&
            (identical(other.ctaLabel, ctaLabel) ||
                other.ctaLabel == ctaLabel) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.lesson, lesson) || other.lesson == lesson) &&
            (identical(other.module, module) || other.module == module) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      state,
      eyebrow,
      title,
      description,
      progressPercentage,
      ctaLabel,
      thumbnailUrl,
      lesson,
      module,
      status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ContinueLearningSectionImplCopyWith<_$ContinueLearningSectionImpl>
      get copyWith => __$$ContinueLearningSectionImplCopyWithImpl<
          _$ContinueLearningSectionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ContinueLearningSectionImplToJson(
      this,
    );
  }
}

abstract class _ContinueLearningSection implements ContinueLearningSection {
  const factory _ContinueLearningSection(
      {required final String state,
      required final String eyebrow,
      required final String title,
      required final String description,
      @JsonKey(name: 'progress_percentage')
      required final int progressPercentage,
      @JsonKey(name: 'cta_label') required final String ctaLabel,
      @JsonKey(name: 'thumbnail_url') final String? thumbnailUrl,
      required final DashboardLesson lesson,
      required final DashboardModule module,
      required final String status}) = _$ContinueLearningSectionImpl;

  factory _ContinueLearningSection.fromJson(Map<String, dynamic> json) =
      _$ContinueLearningSectionImpl.fromJson;

  @override
  String get state;
  @override
  String get eyebrow;
  @override
  String get title;
  @override
  String get description;
  @override
  @JsonKey(name: 'progress_percentage')
  int get progressPercentage;
  @override
  @JsonKey(name: 'cta_label')
  String get ctaLabel;
  @override
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl;
  @override
  DashboardLesson get lesson;
  @override
  DashboardModule get module;
  @override
  String get status;
  @override
  @JsonKey(ignore: true)
  _$$ContinueLearningSectionImplCopyWith<_$ContinueLearningSectionImpl>
      get copyWith => throw _privateConstructorUsedError;
}

DashboardLesson _$DashboardLessonFromJson(Map<String, dynamic> json) {
  return _DashboardLesson.fromJson(json);
}

/// @nodoc
mixin _$DashboardLesson {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'sort_order')
  int get sortOrder => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DashboardLessonCopyWith<DashboardLesson> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardLessonCopyWith<$Res> {
  factory $DashboardLessonCopyWith(
          DashboardLesson value, $Res Function(DashboardLesson) then) =
      _$DashboardLessonCopyWithImpl<$Res, DashboardLesson>;
  @useResult
  $Res call({int id, String title, @JsonKey(name: 'sort_order') int sortOrder});
}

/// @nodoc
class _$DashboardLessonCopyWithImpl<$Res, $Val extends DashboardLesson>
    implements $DashboardLessonCopyWith<$Res> {
  _$DashboardLessonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? sortOrder = null,
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
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DashboardLessonImplCopyWith<$Res>
    implements $DashboardLessonCopyWith<$Res> {
  factory _$$DashboardLessonImplCopyWith(_$DashboardLessonImpl value,
          $Res Function(_$DashboardLessonImpl) then) =
      __$$DashboardLessonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String title, @JsonKey(name: 'sort_order') int sortOrder});
}

/// @nodoc
class __$$DashboardLessonImplCopyWithImpl<$Res>
    extends _$DashboardLessonCopyWithImpl<$Res, _$DashboardLessonImpl>
    implements _$$DashboardLessonImplCopyWith<$Res> {
  __$$DashboardLessonImplCopyWithImpl(
      _$DashboardLessonImpl _value, $Res Function(_$DashboardLessonImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? sortOrder = null,
  }) {
    return _then(_$DashboardLessonImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardLessonImpl implements _DashboardLesson {
  const _$DashboardLessonImpl(
      {required this.id,
      required this.title,
      @JsonKey(name: 'sort_order') required this.sortOrder});

  factory _$DashboardLessonImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardLessonImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  @JsonKey(name: 'sort_order')
  final int sortOrder;

  @override
  String toString() {
    return 'DashboardLesson(id: $id, title: $title, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardLessonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, sortOrder);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardLessonImplCopyWith<_$DashboardLessonImpl> get copyWith =>
      __$$DashboardLessonImplCopyWithImpl<_$DashboardLessonImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardLessonImplToJson(
      this,
    );
  }
}

abstract class _DashboardLesson implements DashboardLesson {
  const factory _DashboardLesson(
          {required final int id,
          required final String title,
          @JsonKey(name: 'sort_order') required final int sortOrder}) =
      _$DashboardLessonImpl;

  factory _DashboardLesson.fromJson(Map<String, dynamic> json) =
      _$DashboardLessonImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  @JsonKey(name: 'sort_order')
  int get sortOrder;
  @override
  @JsonKey(ignore: true)
  _$$DashboardLessonImplCopyWith<_$DashboardLessonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DashboardModule _$DashboardModuleFromJson(Map<String, dynamic> json) {
  return _DashboardModule.fromJson(json);
}

/// @nodoc
mixin _$DashboardModule {
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'url_slug')
  String get urlSlug => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DashboardModuleCopyWith<DashboardModule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardModuleCopyWith<$Res> {
  factory $DashboardModuleCopyWith(
          DashboardModule value, $Res Function(DashboardModule) then) =
      _$DashboardModuleCopyWithImpl<$Res, DashboardModule>;
  @useResult
  $Res call({String title, @JsonKey(name: 'url_slug') String urlSlug});
}

/// @nodoc
class _$DashboardModuleCopyWithImpl<$Res, $Val extends DashboardModule>
    implements $DashboardModuleCopyWith<$Res> {
  _$DashboardModuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? urlSlug = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      urlSlug: null == urlSlug
          ? _value.urlSlug
          : urlSlug // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DashboardModuleImplCopyWith<$Res>
    implements $DashboardModuleCopyWith<$Res> {
  factory _$$DashboardModuleImplCopyWith(_$DashboardModuleImpl value,
          $Res Function(_$DashboardModuleImpl) then) =
      __$$DashboardModuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, @JsonKey(name: 'url_slug') String urlSlug});
}

/// @nodoc
class __$$DashboardModuleImplCopyWithImpl<$Res>
    extends _$DashboardModuleCopyWithImpl<$Res, _$DashboardModuleImpl>
    implements _$$DashboardModuleImplCopyWith<$Res> {
  __$$DashboardModuleImplCopyWithImpl(
      _$DashboardModuleImpl _value, $Res Function(_$DashboardModuleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? urlSlug = null,
  }) {
    return _then(_$DashboardModuleImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      urlSlug: null == urlSlug
          ? _value.urlSlug
          : urlSlug // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardModuleImpl implements _DashboardModule {
  const _$DashboardModuleImpl(
      {required this.title, @JsonKey(name: 'url_slug') required this.urlSlug});

  factory _$DashboardModuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardModuleImplFromJson(json);

  @override
  final String title;
  @override
  @JsonKey(name: 'url_slug')
  final String urlSlug;

  @override
  String toString() {
    return 'DashboardModule(title: $title, urlSlug: $urlSlug)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardModuleImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.urlSlug, urlSlug) || other.urlSlug == urlSlug));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, title, urlSlug);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardModuleImplCopyWith<_$DashboardModuleImpl> get copyWith =>
      __$$DashboardModuleImplCopyWithImpl<_$DashboardModuleImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardModuleImplToJson(
      this,
    );
  }
}

abstract class _DashboardModule implements DashboardModule {
  const factory _DashboardModule(
          {required final String title,
          @JsonKey(name: 'url_slug') required final String urlSlug}) =
      _$DashboardModuleImpl;

  factory _DashboardModule.fromJson(Map<String, dynamic> json) =
      _$DashboardModuleImpl.fromJson;

  @override
  String get title;
  @override
  @JsonKey(name: 'url_slug')
  String get urlSlug;
  @override
  @JsonKey(ignore: true)
  _$$DashboardModuleImplCopyWith<_$DashboardModuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProgressSummarySection _$ProgressSummarySectionFromJson(
    Map<String, dynamic> json) {
  return _ProgressSummarySection.fromJson(json);
}

/// @nodoc
mixin _$ProgressSummarySection {
  String get state => throw _privateConstructorUsedError;
  String get eyebrow => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'overall_progress_percentage')
  int get overallProgressPercentage => throw _privateConstructorUsedError;
  @JsonKey(name: 'modules_completed')
  int get modulesCompleted => throw _privateConstructorUsedError;
  @JsonKey(name: 'modules_total')
  int get modulesTotal => throw _privateConstructorUsedError;
  @JsonKey(name: 'lessons_completed')
  int get lessonsCompleted => throw _privateConstructorUsedError;
  @JsonKey(name: 'lessons_total')
  int get lessonsTotal => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProgressSummarySectionCopyWith<ProgressSummarySection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressSummarySectionCopyWith<$Res> {
  factory $ProgressSummarySectionCopyWith(ProgressSummarySection value,
          $Res Function(ProgressSummarySection) then) =
      _$ProgressSummarySectionCopyWithImpl<$Res, ProgressSummarySection>;
  @useResult
  $Res call(
      {String state,
      String eyebrow,
      String title,
      @JsonKey(name: 'overall_progress_percentage')
      int overallProgressPercentage,
      @JsonKey(name: 'modules_completed') int modulesCompleted,
      @JsonKey(name: 'modules_total') int modulesTotal,
      @JsonKey(name: 'lessons_completed') int lessonsCompleted,
      @JsonKey(name: 'lessons_total') int lessonsTotal,
      String status});
}

/// @nodoc
class _$ProgressSummarySectionCopyWithImpl<$Res,
        $Val extends ProgressSummarySection>
    implements $ProgressSummarySectionCopyWith<$Res> {
  _$ProgressSummarySectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? state = null,
    Object? eyebrow = null,
    Object? title = null,
    Object? overallProgressPercentage = null,
    Object? modulesCompleted = null,
    Object? modulesTotal = null,
    Object? lessonsCompleted = null,
    Object? lessonsTotal = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      eyebrow: null == eyebrow
          ? _value.eyebrow
          : eyebrow // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      overallProgressPercentage: null == overallProgressPercentage
          ? _value.overallProgressPercentage
          : overallProgressPercentage // ignore: cast_nullable_to_non_nullable
              as int,
      modulesCompleted: null == modulesCompleted
          ? _value.modulesCompleted
          : modulesCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      modulesTotal: null == modulesTotal
          ? _value.modulesTotal
          : modulesTotal // ignore: cast_nullable_to_non_nullable
              as int,
      lessonsCompleted: null == lessonsCompleted
          ? _value.lessonsCompleted
          : lessonsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      lessonsTotal: null == lessonsTotal
          ? _value.lessonsTotal
          : lessonsTotal // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProgressSummarySectionImplCopyWith<$Res>
    implements $ProgressSummarySectionCopyWith<$Res> {
  factory _$$ProgressSummarySectionImplCopyWith(
          _$ProgressSummarySectionImpl value,
          $Res Function(_$ProgressSummarySectionImpl) then) =
      __$$ProgressSummarySectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String state,
      String eyebrow,
      String title,
      @JsonKey(name: 'overall_progress_percentage')
      int overallProgressPercentage,
      @JsonKey(name: 'modules_completed') int modulesCompleted,
      @JsonKey(name: 'modules_total') int modulesTotal,
      @JsonKey(name: 'lessons_completed') int lessonsCompleted,
      @JsonKey(name: 'lessons_total') int lessonsTotal,
      String status});
}

/// @nodoc
class __$$ProgressSummarySectionImplCopyWithImpl<$Res>
    extends _$ProgressSummarySectionCopyWithImpl<$Res,
        _$ProgressSummarySectionImpl>
    implements _$$ProgressSummarySectionImplCopyWith<$Res> {
  __$$ProgressSummarySectionImplCopyWithImpl(
      _$ProgressSummarySectionImpl _value,
      $Res Function(_$ProgressSummarySectionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? state = null,
    Object? eyebrow = null,
    Object? title = null,
    Object? overallProgressPercentage = null,
    Object? modulesCompleted = null,
    Object? modulesTotal = null,
    Object? lessonsCompleted = null,
    Object? lessonsTotal = null,
    Object? status = null,
  }) {
    return _then(_$ProgressSummarySectionImpl(
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      eyebrow: null == eyebrow
          ? _value.eyebrow
          : eyebrow // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      overallProgressPercentage: null == overallProgressPercentage
          ? _value.overallProgressPercentage
          : overallProgressPercentage // ignore: cast_nullable_to_non_nullable
              as int,
      modulesCompleted: null == modulesCompleted
          ? _value.modulesCompleted
          : modulesCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      modulesTotal: null == modulesTotal
          ? _value.modulesTotal
          : modulesTotal // ignore: cast_nullable_to_non_nullable
              as int,
      lessonsCompleted: null == lessonsCompleted
          ? _value.lessonsCompleted
          : lessonsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      lessonsTotal: null == lessonsTotal
          ? _value.lessonsTotal
          : lessonsTotal // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgressSummarySectionImpl implements _ProgressSummarySection {
  const _$ProgressSummarySectionImpl(
      {required this.state,
      required this.eyebrow,
      required this.title,
      @JsonKey(name: 'overall_progress_percentage')
      required this.overallProgressPercentage,
      @JsonKey(name: 'modules_completed') required this.modulesCompleted,
      @JsonKey(name: 'modules_total') required this.modulesTotal,
      @JsonKey(name: 'lessons_completed') required this.lessonsCompleted,
      @JsonKey(name: 'lessons_total') required this.lessonsTotal,
      required this.status});

  factory _$ProgressSummarySectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressSummarySectionImplFromJson(json);

  @override
  final String state;
  @override
  final String eyebrow;
  @override
  final String title;
  @override
  @JsonKey(name: 'overall_progress_percentage')
  final int overallProgressPercentage;
  @override
  @JsonKey(name: 'modules_completed')
  final int modulesCompleted;
  @override
  @JsonKey(name: 'modules_total')
  final int modulesTotal;
  @override
  @JsonKey(name: 'lessons_completed')
  final int lessonsCompleted;
  @override
  @JsonKey(name: 'lessons_total')
  final int lessonsTotal;
  @override
  final String status;

  @override
  String toString() {
    return 'ProgressSummarySection(state: $state, eyebrow: $eyebrow, title: $title, overallProgressPercentage: $overallProgressPercentage, modulesCompleted: $modulesCompleted, modulesTotal: $modulesTotal, lessonsCompleted: $lessonsCompleted, lessonsTotal: $lessonsTotal, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressSummarySectionImpl &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.eyebrow, eyebrow) || other.eyebrow == eyebrow) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.overallProgressPercentage,
                    overallProgressPercentage) ||
                other.overallProgressPercentage == overallProgressPercentage) &&
            (identical(other.modulesCompleted, modulesCompleted) ||
                other.modulesCompleted == modulesCompleted) &&
            (identical(other.modulesTotal, modulesTotal) ||
                other.modulesTotal == modulesTotal) &&
            (identical(other.lessonsCompleted, lessonsCompleted) ||
                other.lessonsCompleted == lessonsCompleted) &&
            (identical(other.lessonsTotal, lessonsTotal) ||
                other.lessonsTotal == lessonsTotal) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      state,
      eyebrow,
      title,
      overallProgressPercentage,
      modulesCompleted,
      modulesTotal,
      lessonsCompleted,
      lessonsTotal,
      status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressSummarySectionImplCopyWith<_$ProgressSummarySectionImpl>
      get copyWith => __$$ProgressSummarySectionImplCopyWithImpl<
          _$ProgressSummarySectionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressSummarySectionImplToJson(
      this,
    );
  }
}

abstract class _ProgressSummarySection implements ProgressSummarySection {
  const factory _ProgressSummarySection(
      {required final String state,
      required final String eyebrow,
      required final String title,
      @JsonKey(name: 'overall_progress_percentage')
      required final int overallProgressPercentage,
      @JsonKey(name: 'modules_completed') required final int modulesCompleted,
      @JsonKey(name: 'modules_total') required final int modulesTotal,
      @JsonKey(name: 'lessons_completed') required final int lessonsCompleted,
      @JsonKey(name: 'lessons_total') required final int lessonsTotal,
      required final String status}) = _$ProgressSummarySectionImpl;

  factory _ProgressSummarySection.fromJson(Map<String, dynamic> json) =
      _$ProgressSummarySectionImpl.fromJson;

  @override
  String get state;
  @override
  String get eyebrow;
  @override
  String get title;
  @override
  @JsonKey(name: 'overall_progress_percentage')
  int get overallProgressPercentage;
  @override
  @JsonKey(name: 'modules_completed')
  int get modulesCompleted;
  @override
  @JsonKey(name: 'modules_total')
  int get modulesTotal;
  @override
  @JsonKey(name: 'lessons_completed')
  int get lessonsCompleted;
  @override
  @JsonKey(name: 'lessons_total')
  int get lessonsTotal;
  @override
  String get status;
  @override
  @JsonKey(ignore: true)
  _$$ProgressSummarySectionImplCopyWith<_$ProgressSummarySectionImpl>
      get copyWith => throw _privateConstructorUsedError;
}

DashboardModuleItem _$DashboardModuleItemFromJson(Map<String, dynamic> json) {
  return _DashboardModuleItem.fromJson(json);
}

/// @nodoc
mixin _$DashboardModuleItem {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'url_slug')
  String get urlSlug => throw _privateConstructorUsedError;
  @JsonKey(name: 'lesson_count')
  int get lessonCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'completed_lessons')
  int get completedLessons => throw _privateConstructorUsedError;
  @JsonKey(name: 'progress_percentage')
  int get progressPercentage => throw _privateConstructorUsedError;
  @JsonKey(name: 'show_progress')
  bool get showProgress => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'status_label')
  String get statusLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'cta_label')
  String get ctaLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DashboardModuleItemCopyWith<DashboardModuleItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardModuleItemCopyWith<$Res> {
  factory $DashboardModuleItemCopyWith(
          DashboardModuleItem value, $Res Function(DashboardModuleItem) then) =
      _$DashboardModuleItemCopyWithImpl<$Res, DashboardModuleItem>;
  @useResult
  $Res call(
      {int id,
      String title,
      @JsonKey(name: 'url_slug') String urlSlug,
      @JsonKey(name: 'lesson_count') int lessonCount,
      @JsonKey(name: 'completed_lessons') int completedLessons,
      @JsonKey(name: 'progress_percentage') int progressPercentage,
      @JsonKey(name: 'show_progress') bool showProgress,
      String status,
      @JsonKey(name: 'status_label') String statusLabel,
      @JsonKey(name: 'cta_label') String ctaLabel,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl});
}

/// @nodoc
class _$DashboardModuleItemCopyWithImpl<$Res, $Val extends DashboardModuleItem>
    implements $DashboardModuleItemCopyWith<$Res> {
  _$DashboardModuleItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? urlSlug = null,
    Object? lessonCount = null,
    Object? completedLessons = null,
    Object? progressPercentage = null,
    Object? showProgress = null,
    Object? status = null,
    Object? statusLabel = null,
    Object? ctaLabel = null,
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
      urlSlug: null == urlSlug
          ? _value.urlSlug
          : urlSlug // ignore: cast_nullable_to_non_nullable
              as String,
      lessonCount: null == lessonCount
          ? _value.lessonCount
          : lessonCount // ignore: cast_nullable_to_non_nullable
              as int,
      completedLessons: null == completedLessons
          ? _value.completedLessons
          : completedLessons // ignore: cast_nullable_to_non_nullable
              as int,
      progressPercentage: null == progressPercentage
          ? _value.progressPercentage
          : progressPercentage // ignore: cast_nullable_to_non_nullable
              as int,
      showProgress: null == showProgress
          ? _value.showProgress
          : showProgress // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      statusLabel: null == statusLabel
          ? _value.statusLabel
          : statusLabel // ignore: cast_nullable_to_non_nullable
              as String,
      ctaLabel: null == ctaLabel
          ? _value.ctaLabel
          : ctaLabel // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DashboardModuleItemImplCopyWith<$Res>
    implements $DashboardModuleItemCopyWith<$Res> {
  factory _$$DashboardModuleItemImplCopyWith(_$DashboardModuleItemImpl value,
          $Res Function(_$DashboardModuleItemImpl) then) =
      __$$DashboardModuleItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      @JsonKey(name: 'url_slug') String urlSlug,
      @JsonKey(name: 'lesson_count') int lessonCount,
      @JsonKey(name: 'completed_lessons') int completedLessons,
      @JsonKey(name: 'progress_percentage') int progressPercentage,
      @JsonKey(name: 'show_progress') bool showProgress,
      String status,
      @JsonKey(name: 'status_label') String statusLabel,
      @JsonKey(name: 'cta_label') String ctaLabel,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl});
}

/// @nodoc
class __$$DashboardModuleItemImplCopyWithImpl<$Res>
    extends _$DashboardModuleItemCopyWithImpl<$Res, _$DashboardModuleItemImpl>
    implements _$$DashboardModuleItemImplCopyWith<$Res> {
  __$$DashboardModuleItemImplCopyWithImpl(_$DashboardModuleItemImpl _value,
      $Res Function(_$DashboardModuleItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? urlSlug = null,
    Object? lessonCount = null,
    Object? completedLessons = null,
    Object? progressPercentage = null,
    Object? showProgress = null,
    Object? status = null,
    Object? statusLabel = null,
    Object? ctaLabel = null,
    Object? thumbnailUrl = freezed,
  }) {
    return _then(_$DashboardModuleItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      urlSlug: null == urlSlug
          ? _value.urlSlug
          : urlSlug // ignore: cast_nullable_to_non_nullable
              as String,
      lessonCount: null == lessonCount
          ? _value.lessonCount
          : lessonCount // ignore: cast_nullable_to_non_nullable
              as int,
      completedLessons: null == completedLessons
          ? _value.completedLessons
          : completedLessons // ignore: cast_nullable_to_non_nullable
              as int,
      progressPercentage: null == progressPercentage
          ? _value.progressPercentage
          : progressPercentage // ignore: cast_nullable_to_non_nullable
              as int,
      showProgress: null == showProgress
          ? _value.showProgress
          : showProgress // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      statusLabel: null == statusLabel
          ? _value.statusLabel
          : statusLabel // ignore: cast_nullable_to_non_nullable
              as String,
      ctaLabel: null == ctaLabel
          ? _value.ctaLabel
          : ctaLabel // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardModuleItemImpl implements _DashboardModuleItem {
  const _$DashboardModuleItemImpl(
      {required this.id,
      required this.title,
      @JsonKey(name: 'url_slug') required this.urlSlug,
      @JsonKey(name: 'lesson_count') required this.lessonCount,
      @JsonKey(name: 'completed_lessons') required this.completedLessons,
      @JsonKey(name: 'progress_percentage') required this.progressPercentage,
      @JsonKey(name: 'show_progress') required this.showProgress,
      required this.status,
      @JsonKey(name: 'status_label') required this.statusLabel,
      @JsonKey(name: 'cta_label') required this.ctaLabel,
      @JsonKey(name: 'thumbnail_url') this.thumbnailUrl});

  factory _$DashboardModuleItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardModuleItemImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  @JsonKey(name: 'url_slug')
  final String urlSlug;
  @override
  @JsonKey(name: 'lesson_count')
  final int lessonCount;
  @override
  @JsonKey(name: 'completed_lessons')
  final int completedLessons;
  @override
  @JsonKey(name: 'progress_percentage')
  final int progressPercentage;
  @override
  @JsonKey(name: 'show_progress')
  final bool showProgress;
  @override
  final String status;
  @override
  @JsonKey(name: 'status_label')
  final String statusLabel;
  @override
  @JsonKey(name: 'cta_label')
  final String ctaLabel;
  @override
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  @override
  String toString() {
    return 'DashboardModuleItem(id: $id, title: $title, urlSlug: $urlSlug, lessonCount: $lessonCount, completedLessons: $completedLessons, progressPercentage: $progressPercentage, showProgress: $showProgress, status: $status, statusLabel: $statusLabel, ctaLabel: $ctaLabel, thumbnailUrl: $thumbnailUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardModuleItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.urlSlug, urlSlug) || other.urlSlug == urlSlug) &&
            (identical(other.lessonCount, lessonCount) ||
                other.lessonCount == lessonCount) &&
            (identical(other.completedLessons, completedLessons) ||
                other.completedLessons == completedLessons) &&
            (identical(other.progressPercentage, progressPercentage) ||
                other.progressPercentage == progressPercentage) &&
            (identical(other.showProgress, showProgress) ||
                other.showProgress == showProgress) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.statusLabel, statusLabel) ||
                other.statusLabel == statusLabel) &&
            (identical(other.ctaLabel, ctaLabel) ||
                other.ctaLabel == ctaLabel) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      urlSlug,
      lessonCount,
      completedLessons,
      progressPercentage,
      showProgress,
      status,
      statusLabel,
      ctaLabel,
      thumbnailUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardModuleItemImplCopyWith<_$DashboardModuleItemImpl> get copyWith =>
      __$$DashboardModuleItemImplCopyWithImpl<_$DashboardModuleItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardModuleItemImplToJson(
      this,
    );
  }
}

abstract class _DashboardModuleItem implements DashboardModuleItem {
  const factory _DashboardModuleItem(
      {required final int id,
      required final String title,
      @JsonKey(name: 'url_slug') required final String urlSlug,
      @JsonKey(name: 'lesson_count') required final int lessonCount,
      @JsonKey(name: 'completed_lessons') required final int completedLessons,
      @JsonKey(name: 'progress_percentage')
      required final int progressPercentage,
      @JsonKey(name: 'show_progress') required final bool showProgress,
      required final String status,
      @JsonKey(name: 'status_label') required final String statusLabel,
      @JsonKey(name: 'cta_label') required final String ctaLabel,
      @JsonKey(name: 'thumbnail_url')
      final String? thumbnailUrl}) = _$DashboardModuleItemImpl;

  factory _DashboardModuleItem.fromJson(Map<String, dynamic> json) =
      _$DashboardModuleItemImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  @JsonKey(name: 'url_slug')
  String get urlSlug;
  @override
  @JsonKey(name: 'lesson_count')
  int get lessonCount;
  @override
  @JsonKey(name: 'completed_lessons')
  int get completedLessons;
  @override
  @JsonKey(name: 'progress_percentage')
  int get progressPercentage;
  @override
  @JsonKey(name: 'show_progress')
  bool get showProgress;
  @override
  String get status;
  @override
  @JsonKey(name: 'status_label')
  String get statusLabel;
  @override
  @JsonKey(name: 'cta_label')
  String get ctaLabel;
  @override
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl;
  @override
  @JsonKey(ignore: true)
  _$$DashboardModuleItemImplCopyWith<_$DashboardModuleItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AvailableModulesSection _$AvailableModulesSectionFromJson(
    Map<String, dynamic> json) {
  return _AvailableModulesSection.fromJson(json);
}

/// @nodoc
mixin _$AvailableModulesSection {
  String get state => throw _privateConstructorUsedError;
  String get eyebrow => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  List<DashboardModuleItem> get items => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AvailableModulesSectionCopyWith<AvailableModulesSection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AvailableModulesSectionCopyWith<$Res> {
  factory $AvailableModulesSectionCopyWith(AvailableModulesSection value,
          $Res Function(AvailableModulesSection) then) =
      _$AvailableModulesSectionCopyWithImpl<$Res, AvailableModulesSection>;
  @useResult
  $Res call(
      {String state,
      String eyebrow,
      String title,
      List<DashboardModuleItem> items});
}

/// @nodoc
class _$AvailableModulesSectionCopyWithImpl<$Res,
        $Val extends AvailableModulesSection>
    implements $AvailableModulesSectionCopyWith<$Res> {
  _$AvailableModulesSectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? state = null,
    Object? eyebrow = null,
    Object? title = null,
    Object? items = null,
  }) {
    return _then(_value.copyWith(
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      eyebrow: null == eyebrow
          ? _value.eyebrow
          : eyebrow // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<DashboardModuleItem>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AvailableModulesSectionImplCopyWith<$Res>
    implements $AvailableModulesSectionCopyWith<$Res> {
  factory _$$AvailableModulesSectionImplCopyWith(
          _$AvailableModulesSectionImpl value,
          $Res Function(_$AvailableModulesSectionImpl) then) =
      __$$AvailableModulesSectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String state,
      String eyebrow,
      String title,
      List<DashboardModuleItem> items});
}

/// @nodoc
class __$$AvailableModulesSectionImplCopyWithImpl<$Res>
    extends _$AvailableModulesSectionCopyWithImpl<$Res,
        _$AvailableModulesSectionImpl>
    implements _$$AvailableModulesSectionImplCopyWith<$Res> {
  __$$AvailableModulesSectionImplCopyWithImpl(
      _$AvailableModulesSectionImpl _value,
      $Res Function(_$AvailableModulesSectionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? state = null,
    Object? eyebrow = null,
    Object? title = null,
    Object? items = null,
  }) {
    return _then(_$AvailableModulesSectionImpl(
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      eyebrow: null == eyebrow
          ? _value.eyebrow
          : eyebrow // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<DashboardModuleItem>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AvailableModulesSectionImpl implements _AvailableModulesSection {
  const _$AvailableModulesSectionImpl(
      {required this.state,
      required this.eyebrow,
      required this.title,
      required final List<DashboardModuleItem> items})
      : _items = items;

  factory _$AvailableModulesSectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$AvailableModulesSectionImplFromJson(json);

  @override
  final String state;
  @override
  final String eyebrow;
  @override
  final String title;
  final List<DashboardModuleItem> _items;
  @override
  List<DashboardModuleItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'AvailableModulesSection(state: $state, eyebrow: $eyebrow, title: $title, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AvailableModulesSectionImpl &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.eyebrow, eyebrow) || other.eyebrow == eyebrow) &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, state, eyebrow, title,
      const DeepCollectionEquality().hash(_items));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AvailableModulesSectionImplCopyWith<_$AvailableModulesSectionImpl>
      get copyWith => __$$AvailableModulesSectionImplCopyWithImpl<
          _$AvailableModulesSectionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AvailableModulesSectionImplToJson(
      this,
    );
  }
}

abstract class _AvailableModulesSection implements AvailableModulesSection {
  const factory _AvailableModulesSection(
          {required final String state,
          required final String eyebrow,
          required final String title,
          required final List<DashboardModuleItem> items}) =
      _$AvailableModulesSectionImpl;

  factory _AvailableModulesSection.fromJson(Map<String, dynamic> json) =
      _$AvailableModulesSectionImpl.fromJson;

  @override
  String get state;
  @override
  String get eyebrow;
  @override
  String get title;
  @override
  List<DashboardModuleItem> get items;
  @override
  @JsonKey(ignore: true)
  _$$AvailableModulesSectionImplCopyWith<_$AvailableModulesSectionImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CertificateMilestone _$CertificateMilestoneFromJson(Map<String, dynamic> json) {
  return _CertificateMilestone.fromJson(json);
}

/// @nodoc
mixin _$CertificateMilestone {
  String get state => throw _privateConstructorUsedError;
  String get eyebrow => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'eligibility_label')
  String get eligibilityLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'cta_label')
  String get ctaLabel => throw _privateConstructorUsedError;
  List<MilestoneItem> get milestones => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CertificateMilestoneCopyWith<CertificateMilestone> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CertificateMilestoneCopyWith<$Res> {
  factory $CertificateMilestoneCopyWith(CertificateMilestone value,
          $Res Function(CertificateMilestone) then) =
      _$CertificateMilestoneCopyWithImpl<$Res, CertificateMilestone>;
  @useResult
  $Res call(
      {String state,
      String eyebrow,
      String title,
      String status,
      @JsonKey(name: 'eligibility_label') String eligibilityLabel,
      @JsonKey(name: 'cta_label') String ctaLabel,
      List<MilestoneItem> milestones});
}

/// @nodoc
class _$CertificateMilestoneCopyWithImpl<$Res,
        $Val extends CertificateMilestone>
    implements $CertificateMilestoneCopyWith<$Res> {
  _$CertificateMilestoneCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? state = null,
    Object? eyebrow = null,
    Object? title = null,
    Object? status = null,
    Object? eligibilityLabel = null,
    Object? ctaLabel = null,
    Object? milestones = null,
  }) {
    return _then(_value.copyWith(
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      eyebrow: null == eyebrow
          ? _value.eyebrow
          : eyebrow // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      eligibilityLabel: null == eligibilityLabel
          ? _value.eligibilityLabel
          : eligibilityLabel // ignore: cast_nullable_to_non_nullable
              as String,
      ctaLabel: null == ctaLabel
          ? _value.ctaLabel
          : ctaLabel // ignore: cast_nullable_to_non_nullable
              as String,
      milestones: null == milestones
          ? _value.milestones
          : milestones // ignore: cast_nullable_to_non_nullable
              as List<MilestoneItem>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CertificateMilestoneImplCopyWith<$Res>
    implements $CertificateMilestoneCopyWith<$Res> {
  factory _$$CertificateMilestoneImplCopyWith(_$CertificateMilestoneImpl value,
          $Res Function(_$CertificateMilestoneImpl) then) =
      __$$CertificateMilestoneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String state,
      String eyebrow,
      String title,
      String status,
      @JsonKey(name: 'eligibility_label') String eligibilityLabel,
      @JsonKey(name: 'cta_label') String ctaLabel,
      List<MilestoneItem> milestones});
}

/// @nodoc
class __$$CertificateMilestoneImplCopyWithImpl<$Res>
    extends _$CertificateMilestoneCopyWithImpl<$Res, _$CertificateMilestoneImpl>
    implements _$$CertificateMilestoneImplCopyWith<$Res> {
  __$$CertificateMilestoneImplCopyWithImpl(_$CertificateMilestoneImpl _value,
      $Res Function(_$CertificateMilestoneImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? state = null,
    Object? eyebrow = null,
    Object? title = null,
    Object? status = null,
    Object? eligibilityLabel = null,
    Object? ctaLabel = null,
    Object? milestones = null,
  }) {
    return _then(_$CertificateMilestoneImpl(
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      eyebrow: null == eyebrow
          ? _value.eyebrow
          : eyebrow // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      eligibilityLabel: null == eligibilityLabel
          ? _value.eligibilityLabel
          : eligibilityLabel // ignore: cast_nullable_to_non_nullable
              as String,
      ctaLabel: null == ctaLabel
          ? _value.ctaLabel
          : ctaLabel // ignore: cast_nullable_to_non_nullable
              as String,
      milestones: null == milestones
          ? _value._milestones
          : milestones // ignore: cast_nullable_to_non_nullable
              as List<MilestoneItem>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CertificateMilestoneImpl implements _CertificateMilestone {
  const _$CertificateMilestoneImpl(
      {required this.state,
      required this.eyebrow,
      required this.title,
      required this.status,
      @JsonKey(name: 'eligibility_label') required this.eligibilityLabel,
      @JsonKey(name: 'cta_label') required this.ctaLabel,
      required final List<MilestoneItem> milestones})
      : _milestones = milestones;

  factory _$CertificateMilestoneImpl.fromJson(Map<String, dynamic> json) =>
      _$$CertificateMilestoneImplFromJson(json);

  @override
  final String state;
  @override
  final String eyebrow;
  @override
  final String title;
  @override
  final String status;
  @override
  @JsonKey(name: 'eligibility_label')
  final String eligibilityLabel;
  @override
  @JsonKey(name: 'cta_label')
  final String ctaLabel;
  final List<MilestoneItem> _milestones;
  @override
  List<MilestoneItem> get milestones {
    if (_milestones is EqualUnmodifiableListView) return _milestones;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_milestones);
  }

  @override
  String toString() {
    return 'CertificateMilestone(state: $state, eyebrow: $eyebrow, title: $title, status: $status, eligibilityLabel: $eligibilityLabel, ctaLabel: $ctaLabel, milestones: $milestones)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CertificateMilestoneImpl &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.eyebrow, eyebrow) || other.eyebrow == eyebrow) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.eligibilityLabel, eligibilityLabel) ||
                other.eligibilityLabel == eligibilityLabel) &&
            (identical(other.ctaLabel, ctaLabel) ||
                other.ctaLabel == ctaLabel) &&
            const DeepCollectionEquality()
                .equals(other._milestones, _milestones));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      state,
      eyebrow,
      title,
      status,
      eligibilityLabel,
      ctaLabel,
      const DeepCollectionEquality().hash(_milestones));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CertificateMilestoneImplCopyWith<_$CertificateMilestoneImpl>
      get copyWith =>
          __$$CertificateMilestoneImplCopyWithImpl<_$CertificateMilestoneImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CertificateMilestoneImplToJson(
      this,
    );
  }
}

abstract class _CertificateMilestone implements CertificateMilestone {
  const factory _CertificateMilestone(
          {required final String state,
          required final String eyebrow,
          required final String title,
          required final String status,
          @JsonKey(name: 'eligibility_label')
          required final String eligibilityLabel,
          @JsonKey(name: 'cta_label') required final String ctaLabel,
          required final List<MilestoneItem> milestones}) =
      _$CertificateMilestoneImpl;

  factory _CertificateMilestone.fromJson(Map<String, dynamic> json) =
      _$CertificateMilestoneImpl.fromJson;

  @override
  String get state;
  @override
  String get eyebrow;
  @override
  String get title;
  @override
  String get status;
  @override
  @JsonKey(name: 'eligibility_label')
  String get eligibilityLabel;
  @override
  @JsonKey(name: 'cta_label')
  String get ctaLabel;
  @override
  List<MilestoneItem> get milestones;
  @override
  @JsonKey(ignore: true)
  _$$CertificateMilestoneImplCopyWith<_$CertificateMilestoneImpl>
      get copyWith => throw _privateConstructorUsedError;
}

MilestoneItem _$MilestoneItemFromJson(Map<String, dynamic> json) {
  return _MilestoneItem.fromJson(json);
}

/// @nodoc
mixin _$MilestoneItem {
  String get label => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get detail => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MilestoneItemCopyWith<MilestoneItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MilestoneItemCopyWith<$Res> {
  factory $MilestoneItemCopyWith(
          MilestoneItem value, $Res Function(MilestoneItem) then) =
      _$MilestoneItemCopyWithImpl<$Res, MilestoneItem>;
  @useResult
  $Res call({String label, String status, String detail});
}

/// @nodoc
class _$MilestoneItemCopyWithImpl<$Res, $Val extends MilestoneItem>
    implements $MilestoneItemCopyWith<$Res> {
  _$MilestoneItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? status = null,
    Object? detail = null,
  }) {
    return _then(_value.copyWith(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      detail: null == detail
          ? _value.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MilestoneItemImplCopyWith<$Res>
    implements $MilestoneItemCopyWith<$Res> {
  factory _$$MilestoneItemImplCopyWith(
          _$MilestoneItemImpl value, $Res Function(_$MilestoneItemImpl) then) =
      __$$MilestoneItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label, String status, String detail});
}

/// @nodoc
class __$$MilestoneItemImplCopyWithImpl<$Res>
    extends _$MilestoneItemCopyWithImpl<$Res, _$MilestoneItemImpl>
    implements _$$MilestoneItemImplCopyWith<$Res> {
  __$$MilestoneItemImplCopyWithImpl(
      _$MilestoneItemImpl _value, $Res Function(_$MilestoneItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? status = null,
    Object? detail = null,
  }) {
    return _then(_$MilestoneItemImpl(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      detail: null == detail
          ? _value.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MilestoneItemImpl implements _MilestoneItem {
  const _$MilestoneItemImpl(
      {required this.label, required this.status, required this.detail});

  factory _$MilestoneItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$MilestoneItemImplFromJson(json);

  @override
  final String label;
  @override
  final String status;
  @override
  final String detail;

  @override
  String toString() {
    return 'MilestoneItem(label: $label, status: $status, detail: $detail)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MilestoneItemImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.detail, detail) || other.detail == detail));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, label, status, detail);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MilestoneItemImplCopyWith<_$MilestoneItemImpl> get copyWith =>
      __$$MilestoneItemImplCopyWithImpl<_$MilestoneItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MilestoneItemImplToJson(
      this,
    );
  }
}

abstract class _MilestoneItem implements MilestoneItem {
  const factory _MilestoneItem(
      {required final String label,
      required final String status,
      required final String detail}) = _$MilestoneItemImpl;

  factory _MilestoneItem.fromJson(Map<String, dynamic> json) =
      _$MilestoneItemImpl.fromJson;

  @override
  String get label;
  @override
  String get status;
  @override
  String get detail;
  @override
  @JsonKey(ignore: true)
  _$$MilestoneItemImplCopyWith<_$MilestoneItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AccessTimeSummary _$AccessTimeSummaryFromJson(Map<String, dynamic> json) {
  return _AccessTimeSummary.fromJson(json);
}

/// @nodoc
mixin _$AccessTimeSummary {
  @JsonKey(name: 'formatted_total_access_duration')
  String get formattedTotal => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_access_duration_seconds')
  int? get totalAccessDurationSeconds => throw _privateConstructorUsedError;
  @JsonKey(name: 'running_total_access_duration_seconds')
  int? get runningTotalAccessDurationSeconds =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'active_session_login_at')
  String? get activeSessionLoginAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_visit_at')
  String? get lastVisitAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'currently_active')
  bool get currentlyActive => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AccessTimeSummaryCopyWith<AccessTimeSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccessTimeSummaryCopyWith<$Res> {
  factory $AccessTimeSummaryCopyWith(
          AccessTimeSummary value, $Res Function(AccessTimeSummary) then) =
      _$AccessTimeSummaryCopyWithImpl<$Res, AccessTimeSummary>;
  @useResult
  $Res call(
      {@JsonKey(name: 'formatted_total_access_duration') String formattedTotal,
      @JsonKey(name: 'total_access_duration_seconds')
      int? totalAccessDurationSeconds,
      @JsonKey(name: 'running_total_access_duration_seconds')
      int? runningTotalAccessDurationSeconds,
      @JsonKey(name: 'active_session_login_at') String? activeSessionLoginAt,
      @JsonKey(name: 'last_visit_at') String? lastVisitAt,
      @JsonKey(name: 'currently_active') bool currentlyActive});
}

/// @nodoc
class _$AccessTimeSummaryCopyWithImpl<$Res, $Val extends AccessTimeSummary>
    implements $AccessTimeSummaryCopyWith<$Res> {
  _$AccessTimeSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? formattedTotal = null,
    Object? totalAccessDurationSeconds = freezed,
    Object? runningTotalAccessDurationSeconds = freezed,
    Object? activeSessionLoginAt = freezed,
    Object? lastVisitAt = freezed,
    Object? currentlyActive = null,
  }) {
    return _then(_value.copyWith(
      formattedTotal: null == formattedTotal
          ? _value.formattedTotal
          : formattedTotal // ignore: cast_nullable_to_non_nullable
              as String,
      totalAccessDurationSeconds: freezed == totalAccessDurationSeconds
          ? _value.totalAccessDurationSeconds
          : totalAccessDurationSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      runningTotalAccessDurationSeconds:
          freezed == runningTotalAccessDurationSeconds
              ? _value.runningTotalAccessDurationSeconds
              : runningTotalAccessDurationSeconds // ignore: cast_nullable_to_non_nullable
                  as int?,
      activeSessionLoginAt: freezed == activeSessionLoginAt
          ? _value.activeSessionLoginAt
          : activeSessionLoginAt // ignore: cast_nullable_to_non_nullable
              as String?,
      lastVisitAt: freezed == lastVisitAt
          ? _value.lastVisitAt
          : lastVisitAt // ignore: cast_nullable_to_non_nullable
              as String?,
      currentlyActive: null == currentlyActive
          ? _value.currentlyActive
          : currentlyActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AccessTimeSummaryImplCopyWith<$Res>
    implements $AccessTimeSummaryCopyWith<$Res> {
  factory _$$AccessTimeSummaryImplCopyWith(_$AccessTimeSummaryImpl value,
          $Res Function(_$AccessTimeSummaryImpl) then) =
      __$$AccessTimeSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'formatted_total_access_duration') String formattedTotal,
      @JsonKey(name: 'total_access_duration_seconds')
      int? totalAccessDurationSeconds,
      @JsonKey(name: 'running_total_access_duration_seconds')
      int? runningTotalAccessDurationSeconds,
      @JsonKey(name: 'active_session_login_at') String? activeSessionLoginAt,
      @JsonKey(name: 'last_visit_at') String? lastVisitAt,
      @JsonKey(name: 'currently_active') bool currentlyActive});
}

/// @nodoc
class __$$AccessTimeSummaryImplCopyWithImpl<$Res>
    extends _$AccessTimeSummaryCopyWithImpl<$Res, _$AccessTimeSummaryImpl>
    implements _$$AccessTimeSummaryImplCopyWith<$Res> {
  __$$AccessTimeSummaryImplCopyWithImpl(_$AccessTimeSummaryImpl _value,
      $Res Function(_$AccessTimeSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? formattedTotal = null,
    Object? totalAccessDurationSeconds = freezed,
    Object? runningTotalAccessDurationSeconds = freezed,
    Object? activeSessionLoginAt = freezed,
    Object? lastVisitAt = freezed,
    Object? currentlyActive = null,
  }) {
    return _then(_$AccessTimeSummaryImpl(
      formattedTotal: null == formattedTotal
          ? _value.formattedTotal
          : formattedTotal // ignore: cast_nullable_to_non_nullable
              as String,
      totalAccessDurationSeconds: freezed == totalAccessDurationSeconds
          ? _value.totalAccessDurationSeconds
          : totalAccessDurationSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      runningTotalAccessDurationSeconds:
          freezed == runningTotalAccessDurationSeconds
              ? _value.runningTotalAccessDurationSeconds
              : runningTotalAccessDurationSeconds // ignore: cast_nullable_to_non_nullable
                  as int?,
      activeSessionLoginAt: freezed == activeSessionLoginAt
          ? _value.activeSessionLoginAt
          : activeSessionLoginAt // ignore: cast_nullable_to_non_nullable
              as String?,
      lastVisitAt: freezed == lastVisitAt
          ? _value.lastVisitAt
          : lastVisitAt // ignore: cast_nullable_to_non_nullable
              as String?,
      currentlyActive: null == currentlyActive
          ? _value.currentlyActive
          : currentlyActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AccessTimeSummaryImpl implements _AccessTimeSummary {
  const _$AccessTimeSummaryImpl(
      {@JsonKey(name: 'formatted_total_access_duration')
      required this.formattedTotal,
      @JsonKey(name: 'total_access_duration_seconds')
      this.totalAccessDurationSeconds,
      @JsonKey(name: 'running_total_access_duration_seconds')
      this.runningTotalAccessDurationSeconds,
      @JsonKey(name: 'active_session_login_at') this.activeSessionLoginAt,
      @JsonKey(name: 'last_visit_at') this.lastVisitAt,
      @JsonKey(name: 'currently_active') required this.currentlyActive});

  factory _$AccessTimeSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccessTimeSummaryImplFromJson(json);

  @override
  @JsonKey(name: 'formatted_total_access_duration')
  final String formattedTotal;
  @override
  @JsonKey(name: 'total_access_duration_seconds')
  final int? totalAccessDurationSeconds;
  @override
  @JsonKey(name: 'running_total_access_duration_seconds')
  final int? runningTotalAccessDurationSeconds;
  @override
  @JsonKey(name: 'active_session_login_at')
  final String? activeSessionLoginAt;
  @override
  @JsonKey(name: 'last_visit_at')
  final String? lastVisitAt;
  @override
  @JsonKey(name: 'currently_active')
  final bool currentlyActive;

  @override
  String toString() {
    return 'AccessTimeSummary(formattedTotal: $formattedTotal, totalAccessDurationSeconds: $totalAccessDurationSeconds, runningTotalAccessDurationSeconds: $runningTotalAccessDurationSeconds, activeSessionLoginAt: $activeSessionLoginAt, lastVisitAt: $lastVisitAt, currentlyActive: $currentlyActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccessTimeSummaryImpl &&
            (identical(other.formattedTotal, formattedTotal) ||
                other.formattedTotal == formattedTotal) &&
            (identical(
                    other.totalAccessDurationSeconds, totalAccessDurationSeconds) ||
                other.totalAccessDurationSeconds ==
                    totalAccessDurationSeconds) &&
            (identical(other.runningTotalAccessDurationSeconds,
                    runningTotalAccessDurationSeconds) ||
                other.runningTotalAccessDurationSeconds ==
                    runningTotalAccessDurationSeconds) &&
            (identical(other.activeSessionLoginAt, activeSessionLoginAt) ||
                other.activeSessionLoginAt == activeSessionLoginAt) &&
            (identical(other.lastVisitAt, lastVisitAt) ||
                other.lastVisitAt == lastVisitAt) &&
            (identical(other.currentlyActive, currentlyActive) ||
                other.currentlyActive == currentlyActive));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(
          runtimeType,
          formattedTotal,
          totalAccessDurationSeconds,
          runningTotalAccessDurationSeconds,
          activeSessionLoginAt,
          lastVisitAt,
          currentlyActive);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AccessTimeSummaryImplCopyWith<_$AccessTimeSummaryImpl> get copyWith =>
      __$$AccessTimeSummaryImplCopyWithImpl<_$AccessTimeSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AccessTimeSummaryImplToJson(
      this,
    );
  }
}

abstract class _AccessTimeSummary implements AccessTimeSummary {
  const factory _AccessTimeSummary(
      {@JsonKey(name: 'formatted_total_access_duration')
      required final String formattedTotal,
      @JsonKey(name: 'total_access_duration_seconds')
      final int? totalAccessDurationSeconds,
      @JsonKey(name: 'running_total_access_duration_seconds')
      final int? runningTotalAccessDurationSeconds,
      @JsonKey(name: 'active_session_login_at')
      final String? activeSessionLoginAt,
      @JsonKey(name: 'last_visit_at') final String? lastVisitAt,
      @JsonKey(name: 'currently_active')
      required final bool currentlyActive}) = _$AccessTimeSummaryImpl;

  factory _AccessTimeSummary.fromJson(Map<String, dynamic> json) =
      _$AccessTimeSummaryImpl.fromJson;

  @override
  @JsonKey(name: 'formatted_total_access_duration')
  String get formattedTotal;
  @override
  @JsonKey(name: 'total_access_duration_seconds')
  int? get totalAccessDurationSeconds;
  @override
  @JsonKey(name: 'running_total_access_duration_seconds')
  int? get runningTotalAccessDurationSeconds;
  @override
  @JsonKey(name: 'active_session_login_at')
  String? get activeSessionLoginAt;
  @override
  @JsonKey(name: 'last_visit_at')
  String? get lastVisitAt;
  @override
  @JsonKey(name: 'currently_active')
  bool get currentlyActive;
  @override
  @JsonKey(ignore: true)
  _$$AccessTimeSummaryImplCopyWith<_$AccessTimeSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DashboardData _$DashboardDataFromJson(Map<String, dynamic> json) {
  return _DashboardData.fromJson(json);
}

/// @nodoc
mixin _$DashboardData {
  DashboardStudent get student => throw _privateConstructorUsedError;
  @JsonKey(name: 'continue_learning_section')
  ContinueLearningSection get continueLearningSection =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'progress_summary_section')
  ProgressSummarySection get progressSummarySection =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'available_modules_section')
  AvailableModulesSection get availableModulesSection =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'certificate_milestone')
  CertificateMilestone get certificateMilestone =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'access_time_summary')
  AccessTimeSummary get accessTimeSummary => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DashboardDataCopyWith<DashboardData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardDataCopyWith<$Res> {
  factory $DashboardDataCopyWith(
          DashboardData value, $Res Function(DashboardData) then) =
      _$DashboardDataCopyWithImpl<$Res, DashboardData>;
  @useResult
  $Res call(
      {DashboardStudent student,
      @JsonKey(name: 'continue_learning_section')
      ContinueLearningSection continueLearningSection,
      @JsonKey(name: 'progress_summary_section')
      ProgressSummarySection progressSummarySection,
      @JsonKey(name: 'available_modules_section')
      AvailableModulesSection availableModulesSection,
      @JsonKey(name: 'certificate_milestone')
      CertificateMilestone certificateMilestone,
      @JsonKey(name: 'access_time_summary')
      AccessTimeSummary accessTimeSummary});

  $DashboardStudentCopyWith<$Res> get student;
  $ContinueLearningSectionCopyWith<$Res> get continueLearningSection;
  $ProgressSummarySectionCopyWith<$Res> get progressSummarySection;
  $AvailableModulesSectionCopyWith<$Res> get availableModulesSection;
  $CertificateMilestoneCopyWith<$Res> get certificateMilestone;
  $AccessTimeSummaryCopyWith<$Res> get accessTimeSummary;
}

/// @nodoc
class _$DashboardDataCopyWithImpl<$Res, $Val extends DashboardData>
    implements $DashboardDataCopyWith<$Res> {
  _$DashboardDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? student = null,
    Object? continueLearningSection = null,
    Object? progressSummarySection = null,
    Object? availableModulesSection = null,
    Object? certificateMilestone = null,
    Object? accessTimeSummary = null,
  }) {
    return _then(_value.copyWith(
      student: null == student
          ? _value.student
          : student // ignore: cast_nullable_to_non_nullable
              as DashboardStudent,
      continueLearningSection: null == continueLearningSection
          ? _value.continueLearningSection
          : continueLearningSection // ignore: cast_nullable_to_non_nullable
              as ContinueLearningSection,
      progressSummarySection: null == progressSummarySection
          ? _value.progressSummarySection
          : progressSummarySection // ignore: cast_nullable_to_non_nullable
              as ProgressSummarySection,
      availableModulesSection: null == availableModulesSection
          ? _value.availableModulesSection
          : availableModulesSection // ignore: cast_nullable_to_non_nullable
              as AvailableModulesSection,
      certificateMilestone: null == certificateMilestone
          ? _value.certificateMilestone
          : certificateMilestone // ignore: cast_nullable_to_non_nullable
              as CertificateMilestone,
      accessTimeSummary: null == accessTimeSummary
          ? _value.accessTimeSummary
          : accessTimeSummary // ignore: cast_nullable_to_non_nullable
              as AccessTimeSummary,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $DashboardStudentCopyWith<$Res> get student {
    return $DashboardStudentCopyWith<$Res>(_value.student, (value) {
      return _then(_value.copyWith(student: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ContinueLearningSectionCopyWith<$Res> get continueLearningSection {
    return $ContinueLearningSectionCopyWith<$Res>(
        _value.continueLearningSection, (value) {
      return _then(_value.copyWith(continueLearningSection: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ProgressSummarySectionCopyWith<$Res> get progressSummarySection {
    return $ProgressSummarySectionCopyWith<$Res>(_value.progressSummarySection,
        (value) {
      return _then(_value.copyWith(progressSummarySection: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AvailableModulesSectionCopyWith<$Res> get availableModulesSection {
    return $AvailableModulesSectionCopyWith<$Res>(
        _value.availableModulesSection, (value) {
      return _then(_value.copyWith(availableModulesSection: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $CertificateMilestoneCopyWith<$Res> get certificateMilestone {
    return $CertificateMilestoneCopyWith<$Res>(_value.certificateMilestone,
        (value) {
      return _then(_value.copyWith(certificateMilestone: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AccessTimeSummaryCopyWith<$Res> get accessTimeSummary {
    return $AccessTimeSummaryCopyWith<$Res>(_value.accessTimeSummary, (value) {
      return _then(_value.copyWith(accessTimeSummary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DashboardDataImplCopyWith<$Res>
    implements $DashboardDataCopyWith<$Res> {
  factory _$$DashboardDataImplCopyWith(
          _$DashboardDataImpl value, $Res Function(_$DashboardDataImpl) then) =
      __$$DashboardDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DashboardStudent student,
      @JsonKey(name: 'continue_learning_section')
      ContinueLearningSection continueLearningSection,
      @JsonKey(name: 'progress_summary_section')
      ProgressSummarySection progressSummarySection,
      @JsonKey(name: 'available_modules_section')
      AvailableModulesSection availableModulesSection,
      @JsonKey(name: 'certificate_milestone')
      CertificateMilestone certificateMilestone,
      @JsonKey(name: 'access_time_summary')
      AccessTimeSummary accessTimeSummary});

  @override
  $DashboardStudentCopyWith<$Res> get student;
  @override
  $ContinueLearningSectionCopyWith<$Res> get continueLearningSection;
  @override
  $ProgressSummarySectionCopyWith<$Res> get progressSummarySection;
  @override
  $AvailableModulesSectionCopyWith<$Res> get availableModulesSection;
  @override
  $CertificateMilestoneCopyWith<$Res> get certificateMilestone;
  @override
  $AccessTimeSummaryCopyWith<$Res> get accessTimeSummary;
}

/// @nodoc
class __$$DashboardDataImplCopyWithImpl<$Res>
    extends _$DashboardDataCopyWithImpl<$Res, _$DashboardDataImpl>
    implements _$$DashboardDataImplCopyWith<$Res> {
  __$$DashboardDataImplCopyWithImpl(
      _$DashboardDataImpl _value, $Res Function(_$DashboardDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? student = null,
    Object? continueLearningSection = null,
    Object? progressSummarySection = null,
    Object? availableModulesSection = null,
    Object? certificateMilestone = null,
    Object? accessTimeSummary = null,
  }) {
    return _then(_$DashboardDataImpl(
      student: null == student
          ? _value.student
          : student // ignore: cast_nullable_to_non_nullable
              as DashboardStudent,
      continueLearningSection: null == continueLearningSection
          ? _value.continueLearningSection
          : continueLearningSection // ignore: cast_nullable_to_non_nullable
              as ContinueLearningSection,
      progressSummarySection: null == progressSummarySection
          ? _value.progressSummarySection
          : progressSummarySection // ignore: cast_nullable_to_non_nullable
              as ProgressSummarySection,
      availableModulesSection: null == availableModulesSection
          ? _value.availableModulesSection
          : availableModulesSection // ignore: cast_nullable_to_non_nullable
              as AvailableModulesSection,
      certificateMilestone: null == certificateMilestone
          ? _value.certificateMilestone
          : certificateMilestone // ignore: cast_nullable_to_non_nullable
              as CertificateMilestone,
      accessTimeSummary: null == accessTimeSummary
          ? _value.accessTimeSummary
          : accessTimeSummary // ignore: cast_nullable_to_non_nullable
              as AccessTimeSummary,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardDataImpl implements _DashboardData {
  const _$DashboardDataImpl(
      {required this.student,
      @JsonKey(name: 'continue_learning_section')
      required this.continueLearningSection,
      @JsonKey(name: 'progress_summary_section')
      required this.progressSummarySection,
      @JsonKey(name: 'available_modules_section')
      required this.availableModulesSection,
      @JsonKey(name: 'certificate_milestone')
      required this.certificateMilestone,
      @JsonKey(name: 'access_time_summary') required this.accessTimeSummary});

  factory _$DashboardDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardDataImplFromJson(json);

  @override
  final DashboardStudent student;
  @override
  @JsonKey(name: 'continue_learning_section')
  final ContinueLearningSection continueLearningSection;
  @override
  @JsonKey(name: 'progress_summary_section')
  final ProgressSummarySection progressSummarySection;
  @override
  @JsonKey(name: 'available_modules_section')
  final AvailableModulesSection availableModulesSection;
  @override
  @JsonKey(name: 'certificate_milestone')
  final CertificateMilestone certificateMilestone;
  @override
  @JsonKey(name: 'access_time_summary')
  final AccessTimeSummary accessTimeSummary;

  @override
  String toString() {
    return 'DashboardData(student: $student, continueLearningSection: $continueLearningSection, progressSummarySection: $progressSummarySection, availableModulesSection: $availableModulesSection, certificateMilestone: $certificateMilestone, accessTimeSummary: $accessTimeSummary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardDataImpl &&
            (identical(other.student, student) || other.student == student) &&
            (identical(
                    other.continueLearningSection, continueLearningSection) ||
                other.continueLearningSection == continueLearningSection) &&
            (identical(other.progressSummarySection, progressSummarySection) ||
                other.progressSummarySection == progressSummarySection) &&
            (identical(
                    other.availableModulesSection, availableModulesSection) ||
                other.availableModulesSection == availableModulesSection) &&
            (identical(other.certificateMilestone, certificateMilestone) ||
                other.certificateMilestone == certificateMilestone) &&
            (identical(other.accessTimeSummary, accessTimeSummary) ||
                other.accessTimeSummary == accessTimeSummary));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      student,
      continueLearningSection,
      progressSummarySection,
      availableModulesSection,
      certificateMilestone,
      accessTimeSummary);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardDataImplCopyWith<_$DashboardDataImpl> get copyWith =>
      __$$DashboardDataImplCopyWithImpl<_$DashboardDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardDataImplToJson(
      this,
    );
  }
}

abstract class _DashboardData implements DashboardData {
  const factory _DashboardData(
          {required final DashboardStudent student,
          @JsonKey(name: 'continue_learning_section')
          required final ContinueLearningSection continueLearningSection,
          @JsonKey(name: 'progress_summary_section')
          required final ProgressSummarySection progressSummarySection,
          @JsonKey(name: 'available_modules_section')
          required final AvailableModulesSection availableModulesSection,
          @JsonKey(name: 'certificate_milestone')
          required final CertificateMilestone certificateMilestone,
          @JsonKey(name: 'access_time_summary')
          required final AccessTimeSummary accessTimeSummary}) =
      _$DashboardDataImpl;

  factory _DashboardData.fromJson(Map<String, dynamic> json) =
      _$DashboardDataImpl.fromJson;

  @override
  DashboardStudent get student;
  @override
  @JsonKey(name: 'continue_learning_section')
  ContinueLearningSection get continueLearningSection;
  @override
  @JsonKey(name: 'progress_summary_section')
  ProgressSummarySection get progressSummarySection;
  @override
  @JsonKey(name: 'available_modules_section')
  AvailableModulesSection get availableModulesSection;
  @override
  @JsonKey(name: 'certificate_milestone')
  CertificateMilestone get certificateMilestone;
  @override
  @JsonKey(name: 'access_time_summary')
  AccessTimeSummary get accessTimeSummary;
  @override
  @JsonKey(ignore: true)
  _$$DashboardDataImplCopyWith<_$DashboardDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
