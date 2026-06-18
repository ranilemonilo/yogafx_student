// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ModuleItemImpl _$$ModuleItemImplFromJson(Map<String, dynamic> json) =>
    _$ModuleItemImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      sortOrder: (json['sort_order'] as num).toInt(),
      lessonCount: (json['lesson_count'] as num).toInt(),
      assignmentsCount: (json['assignments_count'] as num).toInt(),
      completedLessons: (json['completed_lessons'] as num).toInt(),
      progressPercentage: (json['progress_percentage'] as num).toInt(),
      showProgress: json['show_progress'] as bool,
      status: json['status'] as String,
      isVisible: json['is_visible'] as bool,
      isComplete: json['is_complete'] as bool,
      certificateEnabled: json['certificate_enabled'] as bool,
      ebookEnabled: json['ebook_enabled'] as bool,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );

Map<String, dynamic> _$$ModuleItemImplToJson(_$ModuleItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'slug': instance.slug,
      'description': instance.description,
      'sort_order': instance.sortOrder,
      'lesson_count': instance.lessonCount,
      'assignments_count': instance.assignmentsCount,
      'completed_lessons': instance.completedLessons,
      'progress_percentage': instance.progressPercentage,
      'show_progress': instance.showProgress,
      'status': instance.status,
      'is_visible': instance.isVisible,
      'is_complete': instance.isComplete,
      'certificate_enabled': instance.certificateEnabled,
      'ebook_enabled': instance.ebookEnabled,
      'thumbnail_url': instance.thumbnailUrl,
    };

_$ModuleListDataImpl _$$ModuleListDataImplFromJson(Map<String, dynamic> json) =>
    _$ModuleListDataImpl(
      items: (json['items'] as List<dynamic>)
          .map((e) => ModuleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary:
          ModuleListSummary.fromJson(json['summary'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ModuleListDataImplToJson(
        _$ModuleListDataImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
      'summary': instance.summary,
    };

_$ModuleListSummaryImpl _$$ModuleListSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$ModuleListSummaryImpl(
      total: (json['total'] as num).toInt(),
      visible: (json['visible'] as num).toInt(),
      completed: (json['completed'] as num).toInt(),
      active: (json['active'] as num).toInt(),
    );

Map<String, dynamic> _$$ModuleListSummaryImplToJson(
        _$ModuleListSummaryImpl instance) =>
    <String, dynamic>{
      'total': instance.total,
      'visible': instance.visible,
      'completed': instance.completed,
      'active': instance.active,
    };

_$ModuleLessonImpl _$$ModuleLessonImplFromJson(Map<String, dynamic> json) =>
    _$ModuleLessonImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      sortOrder: (json['sort_order'] as num).toInt(),
      hasWorkbook: json['has_workbook'] as bool,
      hasVideo: json['has_video'] as bool,
      hasAudio: json['has_audio'] as bool,
      hasContent: json['has_content'] as bool,
      isLocked: json['is_locked'] as bool,
      lockReason: json['lock_reason'] as String?,
      status: json['status'] as String,
      progressPercentage: (json['progress_percentage'] as num).toInt(),
      thumbnailUrl: json['thumbnail_url'] as String?,
    );

Map<String, dynamic> _$$ModuleLessonImplToJson(_$ModuleLessonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'sort_order': instance.sortOrder,
      'has_workbook': instance.hasWorkbook,
      'has_video': instance.hasVideo,
      'has_audio': instance.hasAudio,
      'has_content': instance.hasContent,
      'is_locked': instance.isLocked,
      'lock_reason': instance.lockReason,
      'status': instance.status,
      'progress_percentage': instance.progressPercentage,
      'thumbnail_url': instance.thumbnailUrl,
    };

_$ModuleDetailImpl _$$ModuleDetailImplFromJson(Map<String, dynamic> json) =>
    _$ModuleDetailImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      sortOrder: (json['sort_order'] as num).toInt(),
      lessonCount: (json['lesson_count'] as num).toInt(),
      assignmentsCount: (json['assignments_count'] as num).toInt(),
      completedLessons: (json['completed_lessons'] as num).toInt(),
      progressPercentage: (json['progress_percentage'] as num).toInt(),
      showProgress: json['show_progress'] as bool,
      status: json['status'] as String,
      isVisible: json['is_visible'] as bool,
      isComplete: json['is_complete'] as bool,
      certificateEnabled: json['certificate_enabled'] as bool,
      ebookEnabled: json['ebook_enabled'] as bool,
      thumbnailUrl: json['thumbnail_url'] as String?,
      lessons: (json['lessons'] as List<dynamic>)
          .map((e) => ModuleLesson.fromJson(e as Map<String, dynamic>))
          .toList(),
      assignments: json['assignments'] as List<dynamic>,
    );

Map<String, dynamic> _$$ModuleDetailImplToJson(_$ModuleDetailImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'slug': instance.slug,
      'description': instance.description,
      'sort_order': instance.sortOrder,
      'lesson_count': instance.lessonCount,
      'assignments_count': instance.assignmentsCount,
      'completed_lessons': instance.completedLessons,
      'progress_percentage': instance.progressPercentage,
      'show_progress': instance.showProgress,
      'status': instance.status,
      'is_visible': instance.isVisible,
      'is_complete': instance.isComplete,
      'certificate_enabled': instance.certificateEnabled,
      'ebook_enabled': instance.ebookEnabled,
      'thumbnail_url': instance.thumbnailUrl,
      'lessons': instance.lessons,
      'assignments': instance.assignments,
    };
