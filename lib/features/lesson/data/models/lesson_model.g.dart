// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LessonVideoImpl _$$LessonVideoImplFromJson(Map<String, dynamic> json) =>
    _$LessonVideoImpl(
      videoId: json['video_id'] as String,
      hlsUrl: json['hls_url'] as String,
      isReady: json['is_ready'] as bool,
      isConfigured: json['is_configured'] as bool,
    );

Map<String, dynamic> _$$LessonVideoImplToJson(_$LessonVideoImpl instance) =>
    <String, dynamic>{
      'video_id': instance.videoId,
      'hls_url': instance.hlsUrl,
      'is_ready': instance.isReady,
      'is_configured': instance.isConfigured,
    };

_$LessonAudioImpl _$$LessonAudioImplFromJson(Map<String, dynamic> json) =>
    _$LessonAudioImpl(
      url: json['url'] as String?,
      isAvailable: json['is_available'] as bool,
    );

Map<String, dynamic> _$$LessonAudioImplToJson(_$LessonAudioImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'is_available': instance.isAvailable,
    };

_$LessonWorkbookImpl _$$LessonWorkbookImplFromJson(Map<String, dynamic> json) =>
    _$LessonWorkbookImpl(
      url: json['url'] as String?,
      downloadUrl: json['download_url'] as String?,
      fileName: json['file_name'] as String?,
      isAvailable: json['is_available'] as bool,
    );

Map<String, dynamic> _$$LessonWorkbookImplToJson(
        _$LessonWorkbookImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'download_url': instance.downloadUrl,
      'file_name': instance.fileName,
      'is_available': instance.isAvailable,
    };

_$LessonProgressImpl _$$LessonProgressImplFromJson(Map<String, dynamic> json) =>
    _$LessonProgressImpl(
      watchProgress: (json['watch_progress'] as num).toInt(),
      isWorkbookDownloaded: json['is_workbook_downloaded'] as bool,
      isDone: json['is_done'] as bool,
    );

Map<String, dynamic> _$$LessonProgressImplToJson(
        _$LessonProgressImpl instance) =>
    <String, dynamic>{
      'watch_progress': instance.watchProgress,
      'is_workbook_downloaded': instance.isWorkbookDownloaded,
      'is_done': instance.isDone,
    };

_$LessonModuleImpl _$$LessonModuleImplFromJson(Map<String, dynamic> json) =>
    _$LessonModuleImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      slug: json['slug'] as String,
      lessonCount: (json['lesson_count'] as num).toInt(),
      completedLessons: (json['completed_lessons'] as num).toInt(),
      progressPercentage: (json['progress_percentage'] as num).toInt(),
    );

Map<String, dynamic> _$$LessonModuleImplToJson(_$LessonModuleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'slug': instance.slug,
      'lesson_count': instance.lessonCount,
      'completed_lessons': instance.completedLessons,
      'progress_percentage': instance.progressPercentage,
    };

_$LessonNavItemImpl _$$LessonNavItemImplFromJson(Map<String, dynamic> json) =>
    _$LessonNavItemImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      sortOrder: (json['sort_order'] as num).toInt(),
      thumbnailUrl: json['thumbnail_url'] as String?,
      isLocked: json['is_locked'] as bool,
      lockReason: json['lock_reason'] as String?,
      status: json['status'] as String,
      progressPercentage: (json['progress_percentage'] as num).toInt(),
    );

Map<String, dynamic> _$$LessonNavItemImplToJson(_$LessonNavItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'sort_order': instance.sortOrder,
      'thumbnail_url': instance.thumbnailUrl,
      'is_locked': instance.isLocked,
      'lock_reason': instance.lockReason,
      'status': instance.status,
      'progress_percentage': instance.progressPercentage,
    };

_$NextLessonImpl _$$NextLessonImplFromJson(Map<String, dynamic> json) =>
    _$NextLessonImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      sortOrder: (json['sort_order'] as num).toInt(),
      thumbnailUrl: json['thumbnail_url'] as String?,
      isUnlocked: json['is_unlocked'] as bool,
      lockReason: json['lock_reason'] as String?,
    );

Map<String, dynamic> _$$NextLessonImplToJson(_$NextLessonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'sort_order': instance.sortOrder,
      'thumbnail_url': instance.thumbnailUrl,
      'is_unlocked': instance.isUnlocked,
      'lock_reason': instance.lockReason,
    };

_$LessonDetailImpl _$$LessonDetailImplFromJson(Map<String, dynamic> json) =>
    _$LessonDetailImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      content: json['content'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      isLocked: json['is_locked'] as bool,
      lockReason: json['lock_reason'] as String?,
      video: json['video'] == null
          ? null
          : LessonVideo.fromJson(json['video'] as Map<String, dynamic>),
      audio: LessonAudio.fromJson(json['audio'] as Map<String, dynamic>),
      workbook:
          LessonWorkbook.fromJson(json['workbook'] as Map<String, dynamic>),
      progress:
          LessonProgress.fromJson(json['progress'] as Map<String, dynamic>),
      module: LessonModule.fromJson(json['module'] as Map<String, dynamic>),
      assessment: json['assessment'] as Map<String, dynamic>?,
      navigation: (json['navigation'] as List<dynamic>)
          .map((e) => LessonNavItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextLesson: json['next_lesson'] == null
          ? null
          : NextLesson.fromJson(json['next_lesson'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$LessonDetailImplToJson(_$LessonDetailImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'thumbnail_url': instance.thumbnailUrl,
      'is_locked': instance.isLocked,
      'lock_reason': instance.lockReason,
      'video': instance.video,
      'audio': instance.audio,
      'workbook': instance.workbook,
      'progress': instance.progress,
      'module': instance.module,
      'assessment': instance.assessment,
      'navigation': instance.navigation,
      'next_lesson': instance.nextLesson,
    };
