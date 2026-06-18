import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_model.freezed.dart';
part 'dashboard_model.g.dart';

// --- Student ---
@freezed
class DashboardStudent with _$DashboardStudent {
  const factory DashboardStudent({
    required int id,
    required String name,
    required String email,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'access_tier') required DashboardTier accessTier,
  }) = _DashboardStudent;

  factory DashboardStudent.fromJson(Map<String, dynamic> json) =>
      _$DashboardStudentFromJson(json);
}

@freezed
class DashboardTier with _$DashboardTier {
  const factory DashboardTier({
    required int id,
    required String name,
    required String slug,
  }) = _DashboardTier;

  factory DashboardTier.fromJson(Map<String, dynamic> json) =>
      _$DashboardTierFromJson(json);
}

// --- Continue Learning ---
@freezed
class ContinueLearningSection with _$ContinueLearningSection {
  const factory ContinueLearningSection({
    required String state,
    required String eyebrow,
    required String title,
    required String description,
    @JsonKey(name: 'progress_percentage') required int progressPercentage,
    @JsonKey(name: 'cta_label') required String ctaLabel,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    required DashboardLesson lesson,
    required DashboardModule module,
    required String status,
  }) = _ContinueLearningSection;

  factory ContinueLearningSection.fromJson(Map<String, dynamic> json) =>
      _$ContinueLearningSectionFromJson(json);
}

@freezed
class DashboardLesson with _$DashboardLesson {
  const factory DashboardLesson({
    required int id,
    required String title,
    @JsonKey(name: 'sort_order') required int sortOrder,
  }) = _DashboardLesson;

  factory DashboardLesson.fromJson(Map<String, dynamic> json) =>
      _$DashboardLessonFromJson(json);
}

@freezed
class DashboardModule with _$DashboardModule {
  const factory DashboardModule({
    required String title,
    @JsonKey(name: 'url_slug') required String urlSlug,
  }) = _DashboardModule;

  factory DashboardModule.fromJson(Map<String, dynamic> json) =>
      _$DashboardModuleFromJson(json);
}

// --- Progress Summary ---
@freezed
class ProgressSummarySection with _$ProgressSummarySection {
  const factory ProgressSummarySection({
    required String state,
    required String eyebrow,
    required String title,
    @JsonKey(name: 'overall_progress_percentage') required int overallProgressPercentage,
    @JsonKey(name: 'modules_completed') required int modulesCompleted,
    @JsonKey(name: 'modules_total') required int modulesTotal,
    @JsonKey(name: 'lessons_completed') required int lessonsCompleted,
    @JsonKey(name: 'lessons_total') required int lessonsTotal,
    required String status,
  }) = _ProgressSummarySection;

  factory ProgressSummarySection.fromJson(Map<String, dynamic> json) =>
      _$ProgressSummarySectionFromJson(json);
}

// --- Module Item ---
@freezed
class DashboardModuleItem with _$DashboardModuleItem {
  const factory DashboardModuleItem({
    required int id,
    required String title,
    @JsonKey(name: 'url_slug') required String urlSlug,
    @JsonKey(name: 'lesson_count') required int lessonCount,
    @JsonKey(name: 'completed_lessons') required int completedLessons,
    @JsonKey(name: 'progress_percentage') required int progressPercentage,
    @JsonKey(name: 'show_progress') required bool showProgress,
    required String status,
    @JsonKey(name: 'status_label') required String statusLabel,
    @JsonKey(name: 'cta_label') required String ctaLabel,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
  }) = _DashboardModuleItem;

  factory DashboardModuleItem.fromJson(Map<String, dynamic> json) =>
      _$DashboardModuleItemFromJson(json);
}

// --- Available Modules Section ---
@freezed
class AvailableModulesSection with _$AvailableModulesSection {
  const factory AvailableModulesSection({
    required String state,
    required String eyebrow,
    required String title,
    required List<DashboardModuleItem> items,
  }) = _AvailableModulesSection;

  factory AvailableModulesSection.fromJson(Map<String, dynamic> json) =>
      _$AvailableModulesSectionFromJson(json);
}

// --- Certificate Milestone ---
@freezed
class CertificateMilestone with _$CertificateMilestone {
  const factory CertificateMilestone({
    required String state,
    required String eyebrow,
    required String title,
    required String status,
    @JsonKey(name: 'eligibility_label') required String eligibilityLabel,
    @JsonKey(name: 'cta_label') required String ctaLabel,
    required List<MilestoneItem> milestones,
  }) = _CertificateMilestone;

  factory CertificateMilestone.fromJson(Map<String, dynamic> json) =>
      _$CertificateMilestoneFromJson(json);
}

@freezed
class MilestoneItem with _$MilestoneItem {
  const factory MilestoneItem({
    required String label,
    required String status,
    required String detail,
  }) = _MilestoneItem;

  factory MilestoneItem.fromJson(Map<String, dynamic> json) =>
      _$MilestoneItemFromJson(json);
}

// --- Access Time ---
@freezed
class AccessTimeSummary with _$AccessTimeSummary {
  const factory AccessTimeSummary({
    @JsonKey(name: 'formatted_total_access_duration') required String formattedTotal,
    @JsonKey(name: 'last_visit_at') String? lastVisitAt,
    @JsonKey(name: 'currently_active') required bool currentlyActive,
  }) = _AccessTimeSummary;

  factory AccessTimeSummary.fromJson(Map<String, dynamic> json) =>
      _$AccessTimeSummaryFromJson(json);
}

// --- Root Dashboard ---
@freezed
class DashboardData with _$DashboardData {
  const factory DashboardData({
    required DashboardStudent student,
    @JsonKey(name: 'continue_learning_section') required ContinueLearningSection continueLearningSection,
    @JsonKey(name: 'progress_summary_section') required ProgressSummarySection progressSummarySection,
    @JsonKey(name: 'available_modules_section') required AvailableModulesSection availableModulesSection,
    @JsonKey(name: 'certificate_milestone') required CertificateMilestone certificateMilestone,
    @JsonKey(name: 'access_time_summary') required AccessTimeSummary accessTimeSummary,
  }) = _DashboardData;

  factory DashboardData.fromJson(Map<String, dynamic> json) =>
      _$DashboardDataFromJson(json);
}