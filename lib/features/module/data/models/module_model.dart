import 'package:freezed_annotation/freezed_annotation.dart';

part 'module_model.freezed.dart';
part 'module_model.g.dart';

@freezed
class ModuleItem with _$ModuleItem {
  const factory ModuleItem({
    required int id,
    required String title,
    required String slug,
    String? description,
    @JsonKey(name: 'sort_order') required int sortOrder,
    @JsonKey(name: 'lesson_count') required int lessonCount,
    @JsonKey(name: 'assignments_count') required int assignmentsCount,
    @JsonKey(name: 'completed_lessons') required int completedLessons,
    @JsonKey(name: 'progress_percentage') required int progressPercentage,
    @JsonKey(name: 'show_progress') required bool showProgress,
    required String status,
    @JsonKey(name: 'is_visible') required bool isVisible,
    @JsonKey(name: 'is_complete') required bool isComplete,
    @JsonKey(name: 'certificate_enabled') required bool certificateEnabled,
    @JsonKey(name: 'ebook_enabled') required bool ebookEnabled,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
  }) = _ModuleItem;

  factory ModuleItem.fromJson(Map<String, dynamic> json) =>
      _$ModuleItemFromJson(json);
}

@freezed
class ModuleListData with _$ModuleListData {
  const factory ModuleListData({
    required List<ModuleItem> items,
    required ModuleListSummary summary,
  }) = _ModuleListData;

  factory ModuleListData.fromJson(Map<String, dynamic> json) =>
      _$ModuleListDataFromJson(json);
}

@freezed
class ModuleListSummary with _$ModuleListSummary {
  const factory ModuleListSummary({
    required int total,
    required int visible,
    required int completed,
    required int active,
  }) = _ModuleListSummary;

  factory ModuleListSummary.fromJson(Map<String, dynamic> json) =>
      _$ModuleListSummaryFromJson(json);
}

// --- Module Detail ---

@freezed
class ModuleLesson with _$ModuleLesson {
  const factory ModuleLesson({
    required int id,
    required String title,
    @JsonKey(name: 'sort_order') required int sortOrder,
    @JsonKey(name: 'has_workbook') required bool hasWorkbook,
    @JsonKey(name: 'has_video') required bool hasVideo,
    @JsonKey(name: 'has_audio') required bool hasAudio,
    @JsonKey(name: 'has_content') required bool hasContent,
    @JsonKey(name: 'is_locked') required bool isLocked,
    @JsonKey(name: 'lock_reason') String? lockReason,
    required String status,
    @JsonKey(name: 'progress_percentage') required int progressPercentage,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
  }) = _ModuleLesson;

  factory ModuleLesson.fromJson(Map<String, dynamic> json) =>
      _$ModuleLessonFromJson(json);
}

@freezed
class ModuleDetail with _$ModuleDetail {
  const factory ModuleDetail({
    required int id,
    required String title,
    required String slug,
    String? description,
    @JsonKey(name: 'sort_order') required int sortOrder,
    @JsonKey(name: 'lesson_count') required int lessonCount,
    @JsonKey(name: 'assignments_count') required int assignmentsCount,
    @JsonKey(name: 'completed_lessons') required int completedLessons,
    @JsonKey(name: 'progress_percentage') required int progressPercentage,
    @JsonKey(name: 'show_progress') required bool showProgress,
    required String status,
    @JsonKey(name: 'is_visible') required bool isVisible,
    @JsonKey(name: 'is_complete') required bool isComplete,
    @JsonKey(name: 'certificate_enabled') required bool certificateEnabled,
    @JsonKey(name: 'ebook_enabled') required bool ebookEnabled,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    required List<ModuleLesson> lessons,
    required List<dynamic> assignments,
  }) = _ModuleDetail;

  factory ModuleDetail.fromJson(Map<String, dynamic> json) =>
      _$ModuleDetailFromJson(json);
}