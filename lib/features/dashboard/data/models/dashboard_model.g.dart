// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardStudentImpl _$$DashboardStudentImplFromJson(
        Map<String, dynamic> json) =>
    _$DashboardStudentImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      accessTier:
          DashboardTier.fromJson(json['access_tier'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$DashboardStudentImplToJson(
        _$DashboardStudentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'first_name': instance.firstName,
      'access_tier': instance.accessTier,
    };

_$DashboardTierImpl _$$DashboardTierImplFromJson(Map<String, dynamic> json) =>
    _$DashboardTierImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
    );

Map<String, dynamic> _$$DashboardTierImplToJson(_$DashboardTierImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
    };

_$ContinueLearningSectionImpl _$$ContinueLearningSectionImplFromJson(
        Map<String, dynamic> json) =>
    _$ContinueLearningSectionImpl(
      state: json['state'] as String,
      eyebrow: json['eyebrow'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      progressPercentage: (json['progress_percentage'] as num).toInt(),
      ctaLabel: json['cta_label'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      lesson: json['lesson'] == null
          ? null
          : DashboardLesson.fromJson(json['lesson'] as Map<String, dynamic>),
      module: json['module'] == null
          ? null
          : DashboardModule.fromJson(json['module'] as Map<String, dynamic>),
      status: json['status'] as String,
    );

Map<String, dynamic> _$$ContinueLearningSectionImplToJson(
        _$ContinueLearningSectionImpl instance) =>
    <String, dynamic>{
      'state': instance.state,
      'eyebrow': instance.eyebrow,
      'title': instance.title,
      'description': instance.description,
      'progress_percentage': instance.progressPercentage,
      'cta_label': instance.ctaLabel,
      'thumbnail_url': instance.thumbnailUrl,
      'lesson': instance.lesson,
      'module': instance.module,
      'status': instance.status,
    };

_$DashboardLessonImpl _$$DashboardLessonImplFromJson(
        Map<String, dynamic> json) =>
    _$DashboardLessonImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      sortOrder: (json['sort_order'] as num).toInt(),
    );

Map<String, dynamic> _$$DashboardLessonImplToJson(
        _$DashboardLessonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'sort_order': instance.sortOrder,
    };

_$DashboardModuleImpl _$$DashboardModuleImplFromJson(
        Map<String, dynamic> json) =>
    _$DashboardModuleImpl(
      title: json['title'] as String,
      urlSlug: json['url_slug'] as String,
    );

Map<String, dynamic> _$$DashboardModuleImplToJson(
        _$DashboardModuleImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'url_slug': instance.urlSlug,
    };

_$ProgressSummarySectionImpl _$$ProgressSummarySectionImplFromJson(
        Map<String, dynamic> json) =>
    _$ProgressSummarySectionImpl(
      state: json['state'] as String,
      eyebrow: json['eyebrow'] as String,
      title: json['title'] as String,
      overallProgressPercentage:
          (json['overall_progress_percentage'] as num).toInt(),
      modulesCompleted: (json['modules_completed'] as num).toInt(),
      modulesTotal: (json['modules_total'] as num).toInt(),
      lessonsCompleted: (json['lessons_completed'] as num).toInt(),
      lessonsTotal: (json['lessons_total'] as num).toInt(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$$ProgressSummarySectionImplToJson(
        _$ProgressSummarySectionImpl instance) =>
    <String, dynamic>{
      'state': instance.state,
      'eyebrow': instance.eyebrow,
      'title': instance.title,
      'overall_progress_percentage': instance.overallProgressPercentage,
      'modules_completed': instance.modulesCompleted,
      'modules_total': instance.modulesTotal,
      'lessons_completed': instance.lessonsCompleted,
      'lessons_total': instance.lessonsTotal,
      'status': instance.status,
    };

_$DashboardModuleItemImpl _$$DashboardModuleItemImplFromJson(
        Map<String, dynamic> json) =>
    _$DashboardModuleItemImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      urlSlug: json['url_slug'] as String,
      lessonCount: (json['lesson_count'] as num).toInt(),
      completedLessons: (json['completed_lessons'] as num).toInt(),
      progressPercentage: (json['progress_percentage'] as num).toInt(),
      showProgress: json['show_progress'] as bool,
      status: json['status'] as String,
      statusLabel: json['status_label'] as String,
      ctaLabel: json['cta_label'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );

Map<String, dynamic> _$$DashboardModuleItemImplToJson(
        _$DashboardModuleItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url_slug': instance.urlSlug,
      'lesson_count': instance.lessonCount,
      'completed_lessons': instance.completedLessons,
      'progress_percentage': instance.progressPercentage,
      'show_progress': instance.showProgress,
      'status': instance.status,
      'status_label': instance.statusLabel,
      'cta_label': instance.ctaLabel,
      'thumbnail_url': instance.thumbnailUrl,
    };

_$AvailableModulesSectionImpl _$$AvailableModulesSectionImplFromJson(
        Map<String, dynamic> json) =>
    _$AvailableModulesSectionImpl(
      state: json['state'] as String,
      eyebrow: json['eyebrow'] as String,
      title: json['title'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => DashboardModuleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$AvailableModulesSectionImplToJson(
        _$AvailableModulesSectionImpl instance) =>
    <String, dynamic>{
      'state': instance.state,
      'eyebrow': instance.eyebrow,
      'title': instance.title,
      'items': instance.items,
    };

_$CertificateMilestoneImpl _$$CertificateMilestoneImplFromJson(
        Map<String, dynamic> json) =>
    _$CertificateMilestoneImpl(
      state: json['state'] as String,
      eyebrow: json['eyebrow'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      eligibilityLabel: json['eligibility_label'] as String,
      ctaLabel: json['cta_label'] as String,
      milestones: (json['milestones'] as List<dynamic>)
          .map((e) => MilestoneItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$CertificateMilestoneImplToJson(
        _$CertificateMilestoneImpl instance) =>
    <String, dynamic>{
      'state': instance.state,
      'eyebrow': instance.eyebrow,
      'title': instance.title,
      'status': instance.status,
      'eligibility_label': instance.eligibilityLabel,
      'cta_label': instance.ctaLabel,
      'milestones': instance.milestones,
    };

_$MilestoneItemImpl _$$MilestoneItemImplFromJson(Map<String, dynamic> json) =>
    _$MilestoneItemImpl(
      label: json['label'] as String,
      status: json['status'] as String,
      detail: json['detail'] as String,
    );

Map<String, dynamic> _$$MilestoneItemImplToJson(_$MilestoneItemImpl instance) =>
    <String, dynamic>{
      'label': instance.label,
      'status': instance.status,
      'detail': instance.detail,
    };

_$AccessTimeSummaryImpl _$$AccessTimeSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$AccessTimeSummaryImpl(
      formattedTotal: json['formatted_total_access_duration'] as String,
      totalAccessDurationSeconds:
          (json['total_access_duration_seconds'] as num?)?.toInt(),
      runningTotalAccessDurationSeconds:
          (json['running_total_access_duration_seconds'] as num?)?.toInt(),
      activeSessionLoginAt: json['active_session_login_at'] as String?,
      lastVisitAt: json['last_visit_at'] as String?,
      currentlyActive: json['currently_active'] as bool,
    );

Map<String, dynamic> _$$AccessTimeSummaryImplToJson(
        _$AccessTimeSummaryImpl instance) =>
    <String, dynamic>{
      'formatted_total_access_duration': instance.formattedTotal,
      'total_access_duration_seconds': instance.totalAccessDurationSeconds,
      'running_total_access_duration_seconds':
          instance.runningTotalAccessDurationSeconds,
      'active_session_login_at': instance.activeSessionLoginAt,
      'last_visit_at': instance.lastVisitAt,
      'currently_active': instance.currentlyActive,
    };

_$DashboardDataImpl _$$DashboardDataImplFromJson(Map<String, dynamic> json) =>
    _$DashboardDataImpl(
      student:
          DashboardStudent.fromJson(json['student'] as Map<String, dynamic>),
      continueLearningSection: ContinueLearningSection.fromJson(
          json['continue_learning_section'] as Map<String, dynamic>),
      progressSummarySection: ProgressSummarySection.fromJson(
          json['progress_summary_section'] as Map<String, dynamic>),
      availableModulesSection: AvailableModulesSection.fromJson(
          json['available_modules_section'] as Map<String, dynamic>),
      certificateMilestone: CertificateMilestone.fromJson(
          json['certificate_milestone'] as Map<String, dynamic>),
      accessTimeSummary: AccessTimeSummary.fromJson(
          json['access_time_summary'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$DashboardDataImplToJson(_$DashboardDataImpl instance) =>
    <String, dynamic>{
      'student': instance.student,
      'continue_learning_section': instance.continueLearningSection,
      'progress_summary_section': instance.progressSummarySection,
      'available_modules_section': instance.availableModulesSection,
      'certificate_milestone': instance.certificateMilestone,
      'access_time_summary': instance.accessTimeSummary,
    };
