// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'module_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ModuleItem _$ModuleItemFromJson(Map<String, dynamic> json) {
  return _ModuleItem.fromJson(json);
}

/// @nodoc
mixin _$ModuleItem {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'sort_order')
  int get sortOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'lesson_count')
  int get lessonCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'assignments_count')
  int get assignmentsCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'completed_lessons')
  int get completedLessons => throw _privateConstructorUsedError;
  @JsonKey(name: 'progress_percentage')
  int get progressPercentage => throw _privateConstructorUsedError;
  @JsonKey(name: 'show_progress')
  bool get showProgress => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_visible')
  bool get isVisible => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_complete')
  bool get isComplete => throw _privateConstructorUsedError;
  @JsonKey(name: 'certificate_enabled')
  bool get certificateEnabled => throw _privateConstructorUsedError;
  @JsonKey(name: 'ebook_enabled')
  bool get ebookEnabled => throw _privateConstructorUsedError;
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ModuleItemCopyWith<ModuleItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModuleItemCopyWith<$Res> {
  factory $ModuleItemCopyWith(
          ModuleItem value, $Res Function(ModuleItem) then) =
      _$ModuleItemCopyWithImpl<$Res, ModuleItem>;
  @useResult
  $Res call(
      {int id,
      String title,
      String slug,
      String? description,
      @JsonKey(name: 'sort_order') int sortOrder,
      @JsonKey(name: 'lesson_count') int lessonCount,
      @JsonKey(name: 'assignments_count') int assignmentsCount,
      @JsonKey(name: 'completed_lessons') int completedLessons,
      @JsonKey(name: 'progress_percentage') int progressPercentage,
      @JsonKey(name: 'show_progress') bool showProgress,
      String status,
      @JsonKey(name: 'is_visible') bool isVisible,
      @JsonKey(name: 'is_complete') bool isComplete,
      @JsonKey(name: 'certificate_enabled') bool certificateEnabled,
      @JsonKey(name: 'ebook_enabled') bool ebookEnabled,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl});
}

/// @nodoc
class _$ModuleItemCopyWithImpl<$Res, $Val extends ModuleItem>
    implements $ModuleItemCopyWith<$Res> {
  _$ModuleItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? slug = null,
    Object? description = freezed,
    Object? sortOrder = null,
    Object? lessonCount = null,
    Object? assignmentsCount = null,
    Object? completedLessons = null,
    Object? progressPercentage = null,
    Object? showProgress = null,
    Object? status = null,
    Object? isVisible = null,
    Object? isComplete = null,
    Object? certificateEnabled = null,
    Object? ebookEnabled = null,
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
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      lessonCount: null == lessonCount
          ? _value.lessonCount
          : lessonCount // ignore: cast_nullable_to_non_nullable
              as int,
      assignmentsCount: null == assignmentsCount
          ? _value.assignmentsCount
          : assignmentsCount // ignore: cast_nullable_to_non_nullable
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
      isVisible: null == isVisible
          ? _value.isVisible
          : isVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      isComplete: null == isComplete
          ? _value.isComplete
          : isComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      certificateEnabled: null == certificateEnabled
          ? _value.certificateEnabled
          : certificateEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      ebookEnabled: null == ebookEnabled
          ? _value.ebookEnabled
          : ebookEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModuleItemImplCopyWith<$Res>
    implements $ModuleItemCopyWith<$Res> {
  factory _$$ModuleItemImplCopyWith(
          _$ModuleItemImpl value, $Res Function(_$ModuleItemImpl) then) =
      __$$ModuleItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      String slug,
      String? description,
      @JsonKey(name: 'sort_order') int sortOrder,
      @JsonKey(name: 'lesson_count') int lessonCount,
      @JsonKey(name: 'assignments_count') int assignmentsCount,
      @JsonKey(name: 'completed_lessons') int completedLessons,
      @JsonKey(name: 'progress_percentage') int progressPercentage,
      @JsonKey(name: 'show_progress') bool showProgress,
      String status,
      @JsonKey(name: 'is_visible') bool isVisible,
      @JsonKey(name: 'is_complete') bool isComplete,
      @JsonKey(name: 'certificate_enabled') bool certificateEnabled,
      @JsonKey(name: 'ebook_enabled') bool ebookEnabled,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl});
}

/// @nodoc
class __$$ModuleItemImplCopyWithImpl<$Res>
    extends _$ModuleItemCopyWithImpl<$Res, _$ModuleItemImpl>
    implements _$$ModuleItemImplCopyWith<$Res> {
  __$$ModuleItemImplCopyWithImpl(
      _$ModuleItemImpl _value, $Res Function(_$ModuleItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? slug = null,
    Object? description = freezed,
    Object? sortOrder = null,
    Object? lessonCount = null,
    Object? assignmentsCount = null,
    Object? completedLessons = null,
    Object? progressPercentage = null,
    Object? showProgress = null,
    Object? status = null,
    Object? isVisible = null,
    Object? isComplete = null,
    Object? certificateEnabled = null,
    Object? ebookEnabled = null,
    Object? thumbnailUrl = freezed,
  }) {
    return _then(_$ModuleItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      lessonCount: null == lessonCount
          ? _value.lessonCount
          : lessonCount // ignore: cast_nullable_to_non_nullable
              as int,
      assignmentsCount: null == assignmentsCount
          ? _value.assignmentsCount
          : assignmentsCount // ignore: cast_nullable_to_non_nullable
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
      isVisible: null == isVisible
          ? _value.isVisible
          : isVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      isComplete: null == isComplete
          ? _value.isComplete
          : isComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      certificateEnabled: null == certificateEnabled
          ? _value.certificateEnabled
          : certificateEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      ebookEnabled: null == ebookEnabled
          ? _value.ebookEnabled
          : ebookEnabled // ignore: cast_nullable_to_non_nullable
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
class _$ModuleItemImpl implements _ModuleItem {
  const _$ModuleItemImpl(
      {required this.id,
      required this.title,
      required this.slug,
      this.description,
      @JsonKey(name: 'sort_order') required this.sortOrder,
      @JsonKey(name: 'lesson_count') required this.lessonCount,
      @JsonKey(name: 'assignments_count') required this.assignmentsCount,
      @JsonKey(name: 'completed_lessons') required this.completedLessons,
      @JsonKey(name: 'progress_percentage') required this.progressPercentage,
      @JsonKey(name: 'show_progress') required this.showProgress,
      required this.status,
      @JsonKey(name: 'is_visible') required this.isVisible,
      @JsonKey(name: 'is_complete') required this.isComplete,
      @JsonKey(name: 'certificate_enabled') required this.certificateEnabled,
      @JsonKey(name: 'ebook_enabled') required this.ebookEnabled,
      @JsonKey(name: 'thumbnail_url') this.thumbnailUrl});

  factory _$ModuleItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModuleItemImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String slug;
  @override
  final String? description;
  @override
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @override
  @JsonKey(name: 'lesson_count')
  final int lessonCount;
  @override
  @JsonKey(name: 'assignments_count')
  final int assignmentsCount;
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
  @JsonKey(name: 'is_visible')
  final bool isVisible;
  @override
  @JsonKey(name: 'is_complete')
  final bool isComplete;
  @override
  @JsonKey(name: 'certificate_enabled')
  final bool certificateEnabled;
  @override
  @JsonKey(name: 'ebook_enabled')
  final bool ebookEnabled;
  @override
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  @override
  String toString() {
    return 'ModuleItem(id: $id, title: $title, slug: $slug, description: $description, sortOrder: $sortOrder, lessonCount: $lessonCount, assignmentsCount: $assignmentsCount, completedLessons: $completedLessons, progressPercentage: $progressPercentage, showProgress: $showProgress, status: $status, isVisible: $isVisible, isComplete: $isComplete, certificateEnabled: $certificateEnabled, ebookEnabled: $ebookEnabled, thumbnailUrl: $thumbnailUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModuleItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.lessonCount, lessonCount) ||
                other.lessonCount == lessonCount) &&
            (identical(other.assignmentsCount, assignmentsCount) ||
                other.assignmentsCount == assignmentsCount) &&
            (identical(other.completedLessons, completedLessons) ||
                other.completedLessons == completedLessons) &&
            (identical(other.progressPercentage, progressPercentage) ||
                other.progressPercentage == progressPercentage) &&
            (identical(other.showProgress, showProgress) ||
                other.showProgress == showProgress) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isVisible, isVisible) ||
                other.isVisible == isVisible) &&
            (identical(other.isComplete, isComplete) ||
                other.isComplete == isComplete) &&
            (identical(other.certificateEnabled, certificateEnabled) ||
                other.certificateEnabled == certificateEnabled) &&
            (identical(other.ebookEnabled, ebookEnabled) ||
                other.ebookEnabled == ebookEnabled) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      slug,
      description,
      sortOrder,
      lessonCount,
      assignmentsCount,
      completedLessons,
      progressPercentage,
      showProgress,
      status,
      isVisible,
      isComplete,
      certificateEnabled,
      ebookEnabled,
      thumbnailUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ModuleItemImplCopyWith<_$ModuleItemImpl> get copyWith =>
      __$$ModuleItemImplCopyWithImpl<_$ModuleItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModuleItemImplToJson(
      this,
    );
  }
}

abstract class _ModuleItem implements ModuleItem {
  const factory _ModuleItem(
      {required final int id,
      required final String title,
      required final String slug,
      final String? description,
      @JsonKey(name: 'sort_order') required final int sortOrder,
      @JsonKey(name: 'lesson_count') required final int lessonCount,
      @JsonKey(name: 'assignments_count') required final int assignmentsCount,
      @JsonKey(name: 'completed_lessons') required final int completedLessons,
      @JsonKey(name: 'progress_percentage')
      required final int progressPercentage,
      @JsonKey(name: 'show_progress') required final bool showProgress,
      required final String status,
      @JsonKey(name: 'is_visible') required final bool isVisible,
      @JsonKey(name: 'is_complete') required final bool isComplete,
      @JsonKey(name: 'certificate_enabled')
      required final bool certificateEnabled,
      @JsonKey(name: 'ebook_enabled') required final bool ebookEnabled,
      @JsonKey(name: 'thumbnail_url')
      final String? thumbnailUrl}) = _$ModuleItemImpl;

  factory _ModuleItem.fromJson(Map<String, dynamic> json) =
      _$ModuleItemImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String get slug;
  @override
  String? get description;
  @override
  @JsonKey(name: 'sort_order')
  int get sortOrder;
  @override
  @JsonKey(name: 'lesson_count')
  int get lessonCount;
  @override
  @JsonKey(name: 'assignments_count')
  int get assignmentsCount;
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
  @JsonKey(name: 'is_visible')
  bool get isVisible;
  @override
  @JsonKey(name: 'is_complete')
  bool get isComplete;
  @override
  @JsonKey(name: 'certificate_enabled')
  bool get certificateEnabled;
  @override
  @JsonKey(name: 'ebook_enabled')
  bool get ebookEnabled;
  @override
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl;
  @override
  @JsonKey(ignore: true)
  _$$ModuleItemImplCopyWith<_$ModuleItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ModuleListData _$ModuleListDataFromJson(Map<String, dynamic> json) {
  return _ModuleListData.fromJson(json);
}

/// @nodoc
mixin _$ModuleListData {
  List<ModuleItem> get items => throw _privateConstructorUsedError;
  ModuleListSummary get summary => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ModuleListDataCopyWith<ModuleListData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModuleListDataCopyWith<$Res> {
  factory $ModuleListDataCopyWith(
          ModuleListData value, $Res Function(ModuleListData) then) =
      _$ModuleListDataCopyWithImpl<$Res, ModuleListData>;
  @useResult
  $Res call({List<ModuleItem> items, ModuleListSummary summary});

  $ModuleListSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class _$ModuleListDataCopyWithImpl<$Res, $Val extends ModuleListData>
    implements $ModuleListDataCopyWith<$Res> {
  _$ModuleListDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? summary = null,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ModuleItem>,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as ModuleListSummary,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ModuleListSummaryCopyWith<$Res> get summary {
    return $ModuleListSummaryCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ModuleListDataImplCopyWith<$Res>
    implements $ModuleListDataCopyWith<$Res> {
  factory _$$ModuleListDataImplCopyWith(_$ModuleListDataImpl value,
          $Res Function(_$ModuleListDataImpl) then) =
      __$$ModuleListDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<ModuleItem> items, ModuleListSummary summary});

  @override
  $ModuleListSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class __$$ModuleListDataImplCopyWithImpl<$Res>
    extends _$ModuleListDataCopyWithImpl<$Res, _$ModuleListDataImpl>
    implements _$$ModuleListDataImplCopyWith<$Res> {
  __$$ModuleListDataImplCopyWithImpl(
      _$ModuleListDataImpl _value, $Res Function(_$ModuleListDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? summary = null,
  }) {
    return _then(_$ModuleListDataImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ModuleItem>,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as ModuleListSummary,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModuleListDataImpl implements _ModuleListData {
  const _$ModuleListDataImpl(
      {required final List<ModuleItem> items, required this.summary})
      : _items = items;

  factory _$ModuleListDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModuleListDataImplFromJson(json);

  final List<ModuleItem> _items;
  @override
  List<ModuleItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final ModuleListSummary summary;

  @override
  String toString() {
    return 'ModuleListData(items: $items, summary: $summary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModuleListDataImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.summary, summary) || other.summary == summary));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_items), summary);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ModuleListDataImplCopyWith<_$ModuleListDataImpl> get copyWith =>
      __$$ModuleListDataImplCopyWithImpl<_$ModuleListDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModuleListDataImplToJson(
      this,
    );
  }
}

abstract class _ModuleListData implements ModuleListData {
  const factory _ModuleListData(
      {required final List<ModuleItem> items,
      required final ModuleListSummary summary}) = _$ModuleListDataImpl;

  factory _ModuleListData.fromJson(Map<String, dynamic> json) =
      _$ModuleListDataImpl.fromJson;

  @override
  List<ModuleItem> get items;
  @override
  ModuleListSummary get summary;
  @override
  @JsonKey(ignore: true)
  _$$ModuleListDataImplCopyWith<_$ModuleListDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ModuleListSummary _$ModuleListSummaryFromJson(Map<String, dynamic> json) {
  return _ModuleListSummary.fromJson(json);
}

/// @nodoc
mixin _$ModuleListSummary {
  int get total => throw _privateConstructorUsedError;
  int get visible => throw _privateConstructorUsedError;
  int get completed => throw _privateConstructorUsedError;
  int get active => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ModuleListSummaryCopyWith<ModuleListSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModuleListSummaryCopyWith<$Res> {
  factory $ModuleListSummaryCopyWith(
          ModuleListSummary value, $Res Function(ModuleListSummary) then) =
      _$ModuleListSummaryCopyWithImpl<$Res, ModuleListSummary>;
  @useResult
  $Res call({int total, int visible, int completed, int active});
}

/// @nodoc
class _$ModuleListSummaryCopyWithImpl<$Res, $Val extends ModuleListSummary>
    implements $ModuleListSummaryCopyWith<$Res> {
  _$ModuleListSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? visible = null,
    Object? completed = null,
    Object? active = null,
  }) {
    return _then(_value.copyWith(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      visible: null == visible
          ? _value.visible
          : visible // ignore: cast_nullable_to_non_nullable
              as int,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as int,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModuleListSummaryImplCopyWith<$Res>
    implements $ModuleListSummaryCopyWith<$Res> {
  factory _$$ModuleListSummaryImplCopyWith(_$ModuleListSummaryImpl value,
          $Res Function(_$ModuleListSummaryImpl) then) =
      __$$ModuleListSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int total, int visible, int completed, int active});
}

/// @nodoc
class __$$ModuleListSummaryImplCopyWithImpl<$Res>
    extends _$ModuleListSummaryCopyWithImpl<$Res, _$ModuleListSummaryImpl>
    implements _$$ModuleListSummaryImplCopyWith<$Res> {
  __$$ModuleListSummaryImplCopyWithImpl(_$ModuleListSummaryImpl _value,
      $Res Function(_$ModuleListSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? visible = null,
    Object? completed = null,
    Object? active = null,
  }) {
    return _then(_$ModuleListSummaryImpl(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      visible: null == visible
          ? _value.visible
          : visible // ignore: cast_nullable_to_non_nullable
              as int,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as int,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModuleListSummaryImpl implements _ModuleListSummary {
  const _$ModuleListSummaryImpl(
      {required this.total,
      required this.visible,
      required this.completed,
      required this.active});

  factory _$ModuleListSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModuleListSummaryImplFromJson(json);

  @override
  final int total;
  @override
  final int visible;
  @override
  final int completed;
  @override
  final int active;

  @override
  String toString() {
    return 'ModuleListSummary(total: $total, visible: $visible, completed: $completed, active: $active)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModuleListSummaryImpl &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.visible, visible) || other.visible == visible) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.active, active) || other.active == active));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, total, visible, completed, active);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ModuleListSummaryImplCopyWith<_$ModuleListSummaryImpl> get copyWith =>
      __$$ModuleListSummaryImplCopyWithImpl<_$ModuleListSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModuleListSummaryImplToJson(
      this,
    );
  }
}

abstract class _ModuleListSummary implements ModuleListSummary {
  const factory _ModuleListSummary(
      {required final int total,
      required final int visible,
      required final int completed,
      required final int active}) = _$ModuleListSummaryImpl;

  factory _ModuleListSummary.fromJson(Map<String, dynamic> json) =
      _$ModuleListSummaryImpl.fromJson;

  @override
  int get total;
  @override
  int get visible;
  @override
  int get completed;
  @override
  int get active;
  @override
  @JsonKey(ignore: true)
  _$$ModuleListSummaryImplCopyWith<_$ModuleListSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ModuleLesson _$ModuleLessonFromJson(Map<String, dynamic> json) {
  return _ModuleLesson.fromJson(json);
}

/// @nodoc
mixin _$ModuleLesson {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'sort_order')
  int get sortOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_workbook')
  bool get hasWorkbook => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_video')
  bool get hasVideo => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_audio')
  bool get hasAudio => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_content')
  bool get hasContent => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_locked')
  bool get isLocked => throw _privateConstructorUsedError;
  @JsonKey(name: 'lock_reason')
  String? get lockReason => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'progress_percentage')
  int get progressPercentage => throw _privateConstructorUsedError;
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ModuleLessonCopyWith<ModuleLesson> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModuleLessonCopyWith<$Res> {
  factory $ModuleLessonCopyWith(
          ModuleLesson value, $Res Function(ModuleLesson) then) =
      _$ModuleLessonCopyWithImpl<$Res, ModuleLesson>;
  @useResult
  $Res call(
      {int id,
      String title,
      @JsonKey(name: 'sort_order') int sortOrder,
      @JsonKey(name: 'has_workbook') bool hasWorkbook,
      @JsonKey(name: 'has_video') bool hasVideo,
      @JsonKey(name: 'has_audio') bool hasAudio,
      @JsonKey(name: 'has_content') bool hasContent,
      @JsonKey(name: 'is_locked') bool isLocked,
      @JsonKey(name: 'lock_reason') String? lockReason,
      String status,
      @JsonKey(name: 'progress_percentage') int progressPercentage,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl});
}

/// @nodoc
class _$ModuleLessonCopyWithImpl<$Res, $Val extends ModuleLesson>
    implements $ModuleLessonCopyWith<$Res> {
  _$ModuleLessonCopyWithImpl(this._value, this._then);

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
    Object? hasWorkbook = null,
    Object? hasVideo = null,
    Object? hasAudio = null,
    Object? hasContent = null,
    Object? isLocked = null,
    Object? lockReason = freezed,
    Object? status = null,
    Object? progressPercentage = null,
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
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      hasWorkbook: null == hasWorkbook
          ? _value.hasWorkbook
          : hasWorkbook // ignore: cast_nullable_to_non_nullable
              as bool,
      hasVideo: null == hasVideo
          ? _value.hasVideo
          : hasVideo // ignore: cast_nullable_to_non_nullable
              as bool,
      hasAudio: null == hasAudio
          ? _value.hasAudio
          : hasAudio // ignore: cast_nullable_to_non_nullable
              as bool,
      hasContent: null == hasContent
          ? _value.hasContent
          : hasContent // ignore: cast_nullable_to_non_nullable
              as bool,
      isLocked: null == isLocked
          ? _value.isLocked
          : isLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      lockReason: freezed == lockReason
          ? _value.lockReason
          : lockReason // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      progressPercentage: null == progressPercentage
          ? _value.progressPercentage
          : progressPercentage // ignore: cast_nullable_to_non_nullable
              as int,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModuleLessonImplCopyWith<$Res>
    implements $ModuleLessonCopyWith<$Res> {
  factory _$$ModuleLessonImplCopyWith(
          _$ModuleLessonImpl value, $Res Function(_$ModuleLessonImpl) then) =
      __$$ModuleLessonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      @JsonKey(name: 'sort_order') int sortOrder,
      @JsonKey(name: 'has_workbook') bool hasWorkbook,
      @JsonKey(name: 'has_video') bool hasVideo,
      @JsonKey(name: 'has_audio') bool hasAudio,
      @JsonKey(name: 'has_content') bool hasContent,
      @JsonKey(name: 'is_locked') bool isLocked,
      @JsonKey(name: 'lock_reason') String? lockReason,
      String status,
      @JsonKey(name: 'progress_percentage') int progressPercentage,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl});
}

/// @nodoc
class __$$ModuleLessonImplCopyWithImpl<$Res>
    extends _$ModuleLessonCopyWithImpl<$Res, _$ModuleLessonImpl>
    implements _$$ModuleLessonImplCopyWith<$Res> {
  __$$ModuleLessonImplCopyWithImpl(
      _$ModuleLessonImpl _value, $Res Function(_$ModuleLessonImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? sortOrder = null,
    Object? hasWorkbook = null,
    Object? hasVideo = null,
    Object? hasAudio = null,
    Object? hasContent = null,
    Object? isLocked = null,
    Object? lockReason = freezed,
    Object? status = null,
    Object? progressPercentage = null,
    Object? thumbnailUrl = freezed,
  }) {
    return _then(_$ModuleLessonImpl(
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
      hasWorkbook: null == hasWorkbook
          ? _value.hasWorkbook
          : hasWorkbook // ignore: cast_nullable_to_non_nullable
              as bool,
      hasVideo: null == hasVideo
          ? _value.hasVideo
          : hasVideo // ignore: cast_nullable_to_non_nullable
              as bool,
      hasAudio: null == hasAudio
          ? _value.hasAudio
          : hasAudio // ignore: cast_nullable_to_non_nullable
              as bool,
      hasContent: null == hasContent
          ? _value.hasContent
          : hasContent // ignore: cast_nullable_to_non_nullable
              as bool,
      isLocked: null == isLocked
          ? _value.isLocked
          : isLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      lockReason: freezed == lockReason
          ? _value.lockReason
          : lockReason // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      progressPercentage: null == progressPercentage
          ? _value.progressPercentage
          : progressPercentage // ignore: cast_nullable_to_non_nullable
              as int,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModuleLessonImpl implements _ModuleLesson {
  const _$ModuleLessonImpl(
      {required this.id,
      required this.title,
      @JsonKey(name: 'sort_order') required this.sortOrder,
      @JsonKey(name: 'has_workbook') required this.hasWorkbook,
      @JsonKey(name: 'has_video') required this.hasVideo,
      @JsonKey(name: 'has_audio') required this.hasAudio,
      @JsonKey(name: 'has_content') required this.hasContent,
      @JsonKey(name: 'is_locked') required this.isLocked,
      @JsonKey(name: 'lock_reason') this.lockReason,
      required this.status,
      @JsonKey(name: 'progress_percentage') required this.progressPercentage,
      @JsonKey(name: 'thumbnail_url') this.thumbnailUrl});

  factory _$ModuleLessonImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModuleLessonImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @override
  @JsonKey(name: 'has_workbook')
  final bool hasWorkbook;
  @override
  @JsonKey(name: 'has_video')
  final bool hasVideo;
  @override
  @JsonKey(name: 'has_audio')
  final bool hasAudio;
  @override
  @JsonKey(name: 'has_content')
  final bool hasContent;
  @override
  @JsonKey(name: 'is_locked')
  final bool isLocked;
  @override
  @JsonKey(name: 'lock_reason')
  final String? lockReason;
  @override
  final String status;
  @override
  @JsonKey(name: 'progress_percentage')
  final int progressPercentage;
  @override
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  @override
  String toString() {
    return 'ModuleLesson(id: $id, title: $title, sortOrder: $sortOrder, hasWorkbook: $hasWorkbook, hasVideo: $hasVideo, hasAudio: $hasAudio, hasContent: $hasContent, isLocked: $isLocked, lockReason: $lockReason, status: $status, progressPercentage: $progressPercentage, thumbnailUrl: $thumbnailUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModuleLessonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.hasWorkbook, hasWorkbook) ||
                other.hasWorkbook == hasWorkbook) &&
            (identical(other.hasVideo, hasVideo) ||
                other.hasVideo == hasVideo) &&
            (identical(other.hasAudio, hasAudio) ||
                other.hasAudio == hasAudio) &&
            (identical(other.hasContent, hasContent) ||
                other.hasContent == hasContent) &&
            (identical(other.isLocked, isLocked) ||
                other.isLocked == isLocked) &&
            (identical(other.lockReason, lockReason) ||
                other.lockReason == lockReason) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.progressPercentage, progressPercentage) ||
                other.progressPercentage == progressPercentage) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      sortOrder,
      hasWorkbook,
      hasVideo,
      hasAudio,
      hasContent,
      isLocked,
      lockReason,
      status,
      progressPercentage,
      thumbnailUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ModuleLessonImplCopyWith<_$ModuleLessonImpl> get copyWith =>
      __$$ModuleLessonImplCopyWithImpl<_$ModuleLessonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModuleLessonImplToJson(
      this,
    );
  }
}

abstract class _ModuleLesson implements ModuleLesson {
  const factory _ModuleLesson(
          {required final int id,
          required final String title,
          @JsonKey(name: 'sort_order') required final int sortOrder,
          @JsonKey(name: 'has_workbook') required final bool hasWorkbook,
          @JsonKey(name: 'has_video') required final bool hasVideo,
          @JsonKey(name: 'has_audio') required final bool hasAudio,
          @JsonKey(name: 'has_content') required final bool hasContent,
          @JsonKey(name: 'is_locked') required final bool isLocked,
          @JsonKey(name: 'lock_reason') final String? lockReason,
          required final String status,
          @JsonKey(name: 'progress_percentage')
          required final int progressPercentage,
          @JsonKey(name: 'thumbnail_url') final String? thumbnailUrl}) =
      _$ModuleLessonImpl;

  factory _ModuleLesson.fromJson(Map<String, dynamic> json) =
      _$ModuleLessonImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  @JsonKey(name: 'sort_order')
  int get sortOrder;
  @override
  @JsonKey(name: 'has_workbook')
  bool get hasWorkbook;
  @override
  @JsonKey(name: 'has_video')
  bool get hasVideo;
  @override
  @JsonKey(name: 'has_audio')
  bool get hasAudio;
  @override
  @JsonKey(name: 'has_content')
  bool get hasContent;
  @override
  @JsonKey(name: 'is_locked')
  bool get isLocked;
  @override
  @JsonKey(name: 'lock_reason')
  String? get lockReason;
  @override
  String get status;
  @override
  @JsonKey(name: 'progress_percentage')
  int get progressPercentage;
  @override
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl;
  @override
  @JsonKey(ignore: true)
  _$$ModuleLessonImplCopyWith<_$ModuleLessonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ModuleDetail _$ModuleDetailFromJson(Map<String, dynamic> json) {
  return _ModuleDetail.fromJson(json);
}

/// @nodoc
mixin _$ModuleDetail {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'sort_order')
  int get sortOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'lesson_count')
  int get lessonCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'assignments_count')
  int get assignmentsCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'completed_lessons')
  int get completedLessons => throw _privateConstructorUsedError;
  @JsonKey(name: 'progress_percentage')
  int get progressPercentage => throw _privateConstructorUsedError;
  @JsonKey(name: 'show_progress')
  bool get showProgress => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_visible')
  bool get isVisible => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_complete')
  bool get isComplete => throw _privateConstructorUsedError;
  @JsonKey(name: 'certificate_enabled')
  bool get certificateEnabled => throw _privateConstructorUsedError;
  @JsonKey(name: 'ebook_enabled')
  bool get ebookEnabled => throw _privateConstructorUsedError;
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  List<ModuleLesson> get lessons => throw _privateConstructorUsedError;
  List<dynamic> get assignments => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ModuleDetailCopyWith<ModuleDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModuleDetailCopyWith<$Res> {
  factory $ModuleDetailCopyWith(
          ModuleDetail value, $Res Function(ModuleDetail) then) =
      _$ModuleDetailCopyWithImpl<$Res, ModuleDetail>;
  @useResult
  $Res call(
      {int id,
      String title,
      String slug,
      String? description,
      @JsonKey(name: 'sort_order') int sortOrder,
      @JsonKey(name: 'lesson_count') int lessonCount,
      @JsonKey(name: 'assignments_count') int assignmentsCount,
      @JsonKey(name: 'completed_lessons') int completedLessons,
      @JsonKey(name: 'progress_percentage') int progressPercentage,
      @JsonKey(name: 'show_progress') bool showProgress,
      String status,
      @JsonKey(name: 'is_visible') bool isVisible,
      @JsonKey(name: 'is_complete') bool isComplete,
      @JsonKey(name: 'certificate_enabled') bool certificateEnabled,
      @JsonKey(name: 'ebook_enabled') bool ebookEnabled,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
      List<ModuleLesson> lessons,
      List<dynamic> assignments});
}

/// @nodoc
class _$ModuleDetailCopyWithImpl<$Res, $Val extends ModuleDetail>
    implements $ModuleDetailCopyWith<$Res> {
  _$ModuleDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? slug = null,
    Object? description = freezed,
    Object? sortOrder = null,
    Object? lessonCount = null,
    Object? assignmentsCount = null,
    Object? completedLessons = null,
    Object? progressPercentage = null,
    Object? showProgress = null,
    Object? status = null,
    Object? isVisible = null,
    Object? isComplete = null,
    Object? certificateEnabled = null,
    Object? ebookEnabled = null,
    Object? thumbnailUrl = freezed,
    Object? lessons = null,
    Object? assignments = null,
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
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      lessonCount: null == lessonCount
          ? _value.lessonCount
          : lessonCount // ignore: cast_nullable_to_non_nullable
              as int,
      assignmentsCount: null == assignmentsCount
          ? _value.assignmentsCount
          : assignmentsCount // ignore: cast_nullable_to_non_nullable
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
      isVisible: null == isVisible
          ? _value.isVisible
          : isVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      isComplete: null == isComplete
          ? _value.isComplete
          : isComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      certificateEnabled: null == certificateEnabled
          ? _value.certificateEnabled
          : certificateEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      ebookEnabled: null == ebookEnabled
          ? _value.ebookEnabled
          : ebookEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      lessons: null == lessons
          ? _value.lessons
          : lessons // ignore: cast_nullable_to_non_nullable
              as List<ModuleLesson>,
      assignments: null == assignments
          ? _value.assignments
          : assignments // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModuleDetailImplCopyWith<$Res>
    implements $ModuleDetailCopyWith<$Res> {
  factory _$$ModuleDetailImplCopyWith(
          _$ModuleDetailImpl value, $Res Function(_$ModuleDetailImpl) then) =
      __$$ModuleDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      String slug,
      String? description,
      @JsonKey(name: 'sort_order') int sortOrder,
      @JsonKey(name: 'lesson_count') int lessonCount,
      @JsonKey(name: 'assignments_count') int assignmentsCount,
      @JsonKey(name: 'completed_lessons') int completedLessons,
      @JsonKey(name: 'progress_percentage') int progressPercentage,
      @JsonKey(name: 'show_progress') bool showProgress,
      String status,
      @JsonKey(name: 'is_visible') bool isVisible,
      @JsonKey(name: 'is_complete') bool isComplete,
      @JsonKey(name: 'certificate_enabled') bool certificateEnabled,
      @JsonKey(name: 'ebook_enabled') bool ebookEnabled,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
      List<ModuleLesson> lessons,
      List<dynamic> assignments});
}

/// @nodoc
class __$$ModuleDetailImplCopyWithImpl<$Res>
    extends _$ModuleDetailCopyWithImpl<$Res, _$ModuleDetailImpl>
    implements _$$ModuleDetailImplCopyWith<$Res> {
  __$$ModuleDetailImplCopyWithImpl(
      _$ModuleDetailImpl _value, $Res Function(_$ModuleDetailImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? slug = null,
    Object? description = freezed,
    Object? sortOrder = null,
    Object? lessonCount = null,
    Object? assignmentsCount = null,
    Object? completedLessons = null,
    Object? progressPercentage = null,
    Object? showProgress = null,
    Object? status = null,
    Object? isVisible = null,
    Object? isComplete = null,
    Object? certificateEnabled = null,
    Object? ebookEnabled = null,
    Object? thumbnailUrl = freezed,
    Object? lessons = null,
    Object? assignments = null,
  }) {
    return _then(_$ModuleDetailImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      lessonCount: null == lessonCount
          ? _value.lessonCount
          : lessonCount // ignore: cast_nullable_to_non_nullable
              as int,
      assignmentsCount: null == assignmentsCount
          ? _value.assignmentsCount
          : assignmentsCount // ignore: cast_nullable_to_non_nullable
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
      isVisible: null == isVisible
          ? _value.isVisible
          : isVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      isComplete: null == isComplete
          ? _value.isComplete
          : isComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      certificateEnabled: null == certificateEnabled
          ? _value.certificateEnabled
          : certificateEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      ebookEnabled: null == ebookEnabled
          ? _value.ebookEnabled
          : ebookEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      lessons: null == lessons
          ? _value._lessons
          : lessons // ignore: cast_nullable_to_non_nullable
              as List<ModuleLesson>,
      assignments: null == assignments
          ? _value._assignments
          : assignments // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModuleDetailImpl implements _ModuleDetail {
  const _$ModuleDetailImpl(
      {required this.id,
      required this.title,
      required this.slug,
      this.description,
      @JsonKey(name: 'sort_order') required this.sortOrder,
      @JsonKey(name: 'lesson_count') required this.lessonCount,
      @JsonKey(name: 'assignments_count') required this.assignmentsCount,
      @JsonKey(name: 'completed_lessons') required this.completedLessons,
      @JsonKey(name: 'progress_percentage') required this.progressPercentage,
      @JsonKey(name: 'show_progress') required this.showProgress,
      required this.status,
      @JsonKey(name: 'is_visible') required this.isVisible,
      @JsonKey(name: 'is_complete') required this.isComplete,
      @JsonKey(name: 'certificate_enabled') required this.certificateEnabled,
      @JsonKey(name: 'ebook_enabled') required this.ebookEnabled,
      @JsonKey(name: 'thumbnail_url') this.thumbnailUrl,
      required final List<ModuleLesson> lessons,
      required final List<dynamic> assignments})
      : _lessons = lessons,
        _assignments = assignments;

  factory _$ModuleDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModuleDetailImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String slug;
  @override
  final String? description;
  @override
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @override
  @JsonKey(name: 'lesson_count')
  final int lessonCount;
  @override
  @JsonKey(name: 'assignments_count')
  final int assignmentsCount;
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
  @JsonKey(name: 'is_visible')
  final bool isVisible;
  @override
  @JsonKey(name: 'is_complete')
  final bool isComplete;
  @override
  @JsonKey(name: 'certificate_enabled')
  final bool certificateEnabled;
  @override
  @JsonKey(name: 'ebook_enabled')
  final bool ebookEnabled;
  @override
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  final List<ModuleLesson> _lessons;
  @override
  List<ModuleLesson> get lessons {
    if (_lessons is EqualUnmodifiableListView) return _lessons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lessons);
  }

  final List<dynamic> _assignments;
  @override
  List<dynamic> get assignments {
    if (_assignments is EqualUnmodifiableListView) return _assignments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_assignments);
  }

  @override
  String toString() {
    return 'ModuleDetail(id: $id, title: $title, slug: $slug, description: $description, sortOrder: $sortOrder, lessonCount: $lessonCount, assignmentsCount: $assignmentsCount, completedLessons: $completedLessons, progressPercentage: $progressPercentage, showProgress: $showProgress, status: $status, isVisible: $isVisible, isComplete: $isComplete, certificateEnabled: $certificateEnabled, ebookEnabled: $ebookEnabled, thumbnailUrl: $thumbnailUrl, lessons: $lessons, assignments: $assignments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModuleDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.lessonCount, lessonCount) ||
                other.lessonCount == lessonCount) &&
            (identical(other.assignmentsCount, assignmentsCount) ||
                other.assignmentsCount == assignmentsCount) &&
            (identical(other.completedLessons, completedLessons) ||
                other.completedLessons == completedLessons) &&
            (identical(other.progressPercentage, progressPercentage) ||
                other.progressPercentage == progressPercentage) &&
            (identical(other.showProgress, showProgress) ||
                other.showProgress == showProgress) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isVisible, isVisible) ||
                other.isVisible == isVisible) &&
            (identical(other.isComplete, isComplete) ||
                other.isComplete == isComplete) &&
            (identical(other.certificateEnabled, certificateEnabled) ||
                other.certificateEnabled == certificateEnabled) &&
            (identical(other.ebookEnabled, ebookEnabled) ||
                other.ebookEnabled == ebookEnabled) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            const DeepCollectionEquality().equals(other._lessons, _lessons) &&
            const DeepCollectionEquality()
                .equals(other._assignments, _assignments));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      slug,
      description,
      sortOrder,
      lessonCount,
      assignmentsCount,
      completedLessons,
      progressPercentage,
      showProgress,
      status,
      isVisible,
      isComplete,
      certificateEnabled,
      ebookEnabled,
      thumbnailUrl,
      const DeepCollectionEquality().hash(_lessons),
      const DeepCollectionEquality().hash(_assignments));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ModuleDetailImplCopyWith<_$ModuleDetailImpl> get copyWith =>
      __$$ModuleDetailImplCopyWithImpl<_$ModuleDetailImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModuleDetailImplToJson(
      this,
    );
  }
}

abstract class _ModuleDetail implements ModuleDetail {
  const factory _ModuleDetail(
      {required final int id,
      required final String title,
      required final String slug,
      final String? description,
      @JsonKey(name: 'sort_order') required final int sortOrder,
      @JsonKey(name: 'lesson_count') required final int lessonCount,
      @JsonKey(name: 'assignments_count') required final int assignmentsCount,
      @JsonKey(name: 'completed_lessons') required final int completedLessons,
      @JsonKey(name: 'progress_percentage')
      required final int progressPercentage,
      @JsonKey(name: 'show_progress') required final bool showProgress,
      required final String status,
      @JsonKey(name: 'is_visible') required final bool isVisible,
      @JsonKey(name: 'is_complete') required final bool isComplete,
      @JsonKey(name: 'certificate_enabled')
      required final bool certificateEnabled,
      @JsonKey(name: 'ebook_enabled') required final bool ebookEnabled,
      @JsonKey(name: 'thumbnail_url') final String? thumbnailUrl,
      required final List<ModuleLesson> lessons,
      required final List<dynamic> assignments}) = _$ModuleDetailImpl;

  factory _ModuleDetail.fromJson(Map<String, dynamic> json) =
      _$ModuleDetailImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String get slug;
  @override
  String? get description;
  @override
  @JsonKey(name: 'sort_order')
  int get sortOrder;
  @override
  @JsonKey(name: 'lesson_count')
  int get lessonCount;
  @override
  @JsonKey(name: 'assignments_count')
  int get assignmentsCount;
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
  @JsonKey(name: 'is_visible')
  bool get isVisible;
  @override
  @JsonKey(name: 'is_complete')
  bool get isComplete;
  @override
  @JsonKey(name: 'certificate_enabled')
  bool get certificateEnabled;
  @override
  @JsonKey(name: 'ebook_enabled')
  bool get ebookEnabled;
  @override
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl;
  @override
  List<ModuleLesson> get lessons;
  @override
  List<dynamic> get assignments;
  @override
  @JsonKey(ignore: true)
  _$$ModuleDetailImplCopyWith<_$ModuleDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
