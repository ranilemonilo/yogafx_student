import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson_model.freezed.dart';
part 'lesson_model.g.dart';

@freezed
class LessonVideo with _$LessonVideo {
  const factory LessonVideo({
    @JsonKey(name: 'video_id') required String videoId,
    @JsonKey(name: 'hls_url') required String hlsUrl,
    @JsonKey(name: 'is_ready') required bool isReady,
    @JsonKey(name: 'is_configured') required bool isConfigured,
  }) = _LessonVideo;

  factory LessonVideo.fromJson(Map<String, dynamic> json) =>
      _$LessonVideoFromJson(json);
}

@freezed
class LessonAudio with _$LessonAudio {
  const factory LessonAudio({
    String? url,
    @JsonKey(name: 'is_available') required bool isAvailable,
  }) = _LessonAudio;

  factory LessonAudio.fromJson(Map<String, dynamic> json) =>
      _$LessonAudioFromJson(json);
}

@freezed
class LessonWorkbook with _$LessonWorkbook {
  const factory LessonWorkbook({
    String? url,
    @JsonKey(name: 'download_url') String? downloadUrl,
    @JsonKey(name: 'file_name') String? fileName,
    @JsonKey(name: 'is_available') required bool isAvailable,
  }) = _LessonWorkbook;

  factory LessonWorkbook.fromJson(Map<String, dynamic> json) =>
      _$LessonWorkbookFromJson(json);
}

@freezed
class LessonProgress with _$LessonProgress {
  const factory LessonProgress({
    @JsonKey(name: 'watch_progress') required int watchProgress,
    @JsonKey(name: 'is_workbook_downloaded') required bool isWorkbookDownloaded,
    @JsonKey(name: 'is_done') required bool isDone,
  }) = _LessonProgress;

  factory LessonProgress.fromJson(Map<String, dynamic> json) =>
      _$LessonProgressFromJson(json);
}

@freezed
class LessonModule with _$LessonModule {
  const factory LessonModule({
    required int id,
    required String title,
    required String slug,
    @JsonKey(name: 'lesson_count') required int lessonCount,
    @JsonKey(name: 'completed_lessons') required int completedLessons,
    @JsonKey(name: 'progress_percentage') required int progressPercentage,
  }) = _LessonModule;

  factory LessonModule.fromJson(Map<String, dynamic> json) =>
      _$LessonModuleFromJson(json);
}

@freezed
class LessonNavItem with _$LessonNavItem {
  const factory LessonNavItem({
    required int id,
    required String title,
    @JsonKey(name: 'sort_order') required int sortOrder,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'is_locked') required bool isLocked,
    @JsonKey(name: 'lock_reason') String? lockReason,
    required String status,
    @JsonKey(name: 'progress_percentage') required int progressPercentage,
  }) = _LessonNavItem;

  factory LessonNavItem.fromJson(Map<String, dynamic> json) =>
      _$LessonNavItemFromJson(json);
}

@freezed
class NextLesson with _$NextLesson {
  const factory NextLesson({
    required int id,
    required String title,
    @JsonKey(name: 'sort_order') required int sortOrder,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'is_unlocked') required bool isUnlocked,
    @JsonKey(name: 'lock_reason') String? lockReason,
  }) = _NextLesson;

  factory NextLesson.fromJson(Map<String, dynamic> json) =>
      _$NextLessonFromJson(json);
}

@freezed
class LessonDetail with _$LessonDetail {
  const factory LessonDetail({
    required int id,
    required String title,
    String? content,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'is_locked') required bool isLocked,
    @JsonKey(name: 'lock_reason') String? lockReason,
    LessonVideo? video,
    required LessonAudio audio,
    required LessonWorkbook workbook,
    required LessonProgress progress,
    required LessonModule module,
    Map<String, dynamic>? assessment,
    required List<LessonNavItem> navigation,
    @JsonKey(name: 'next_lesson') NextLesson? nextLesson,
  }) = _LessonDetail;

  factory LessonDetail.fromJson(Map<String, dynamic> json) =>
      _$LessonDetailFromJson(json);
}