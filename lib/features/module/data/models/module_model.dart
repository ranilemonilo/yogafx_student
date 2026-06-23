enum ModuleContentType {
  lesson,
  videoLecture,
  ebook,
  certificate,
}

ModuleContentType moduleContentTypeFromJson(String? value) {
  switch (value) {
    case 'ebook':
      return ModuleContentType.ebook;
    case 'certificate':
    case 'certification':
    case 'certificates':
      return ModuleContentType.certificate;
    case 'video_lecture':
    case 'video_lecturer':
    case 'video_lectures':
    case 'video':
      return ModuleContentType.videoLecture;
    case 'lesson':
    case 'lessons':
    default:
      return ModuleContentType.lesson;
  }
}

class ModuleItem {
  const ModuleItem({
    required this.id,
    required this.title,
    required this.slug,
    required this.sortOrder,
    required this.lessonCount,
    required this.assignmentsCount,
    required this.completedLessons,
    required this.progressPercentage,
    required this.showProgress,
    required this.status,
    required this.isVisible,
    required this.isComplete,
    required this.moduleType,
    required this.certificateEnabled,
    required this.ebookEnabled,
    required this.viewTypes, // Field Baru
    required this.primaryCtaLabel, // Field Baru
    required this.primaryCtaUrl, // Field Baru
    required this.primaryCtaKind, // Field Baru
    this.description,
    this.thumbnailUrl,
  });

  factory ModuleItem.fromJson(Map<String, dynamic> json) {
    return ModuleItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      lessonCount: json['lesson_count'] as int? ?? 0,
      assignmentsCount: json['assignments_count'] as int? ?? 0,
      completedLessons: json['completed_lessons'] as int? ?? 0,
      progressPercentage: json['progress_percentage'] as int? ?? 0,
      showProgress: json['show_progress'] as bool? ?? false,
      status: json['status'] as String? ?? '',
      isVisible: json['is_visible'] as bool? ?? false,
      isComplete: json['is_complete'] as bool? ?? false,
      moduleType: moduleContentTypeFromJson(json['module_type'] as String?),
      certificateEnabled: json['certificate_enabled'] as bool? ?? false,
      ebookEnabled: json['ebook_enabled'] as bool? ?? false,
      thumbnailUrl: json['thumbnail_url'] as String?,
      // Mapping field baru
      viewTypes: List<String>.from(json['view_types'] ?? []),
      primaryCtaLabel: json['primary_cta_label'] as String?,
      primaryCtaUrl: json['primary_cta_url'] as String?,
      primaryCtaKind: json['primary_cta_kind'] as String?,
    );
  }

  final int id;
  final String title;
  final String slug;
  final String? description;
  final int sortOrder;
  final int lessonCount;
  final int assignmentsCount;
  final int completedLessons;
  final int progressPercentage;
  final bool showProgress;
  final String status;
  final bool isVisible;
  final bool isComplete;
  final ModuleContentType moduleType;
  final bool certificateEnabled;
  final bool ebookEnabled;
  final String? thumbnailUrl;

  // Field baru
  final List<String> viewTypes;
  final String? primaryCtaLabel;
  final String? primaryCtaUrl;
  final String? primaryCtaKind;
}

class ModuleListData {
  const ModuleListData({
    required this.items,
    required this.summary,
  });

  factory ModuleListData.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return ModuleListData(
      items: rawItems
          .map((item) => ModuleItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      summary: ModuleListSummary.fromJson(
        json['summary'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }

  final List<ModuleItem> items;
  final ModuleListSummary summary;
}

class ModuleListSummary {
  const ModuleListSummary({
    required this.total,
    required this.visible,
    required this.completed,
    required this.active,
  });

  factory ModuleListSummary.fromJson(Map<String, dynamic> json) {
    return ModuleListSummary(
      total: json['total'] as int? ?? 0,
      visible: json['visible'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
      active: json['active'] as int? ?? 0,
    );
  }

  final int total;
  final int visible;
  final int completed;
  final int active;
}

class ModuleLesson {
  const ModuleLesson({
    required this.id,
    required this.title,
    required this.sortOrder,
    required this.hasWorkbook,
    required this.hasVideo,
    required this.hasAudio,
    required this.hasContent,
    required this.isLocked,
    required this.status,
    required this.progressPercentage,
    this.lockReason,
    this.thumbnailUrl,
  });

  factory ModuleLesson.fromJson(Map<String, dynamic> json) {
    return ModuleLesson(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      sortOrder: json['sort_order'] as int? ?? 0,
      hasWorkbook: json['has_workbook'] as bool? ?? false,
      hasVideo: json['has_video'] as bool? ?? false,
      hasAudio: json['has_audio'] as bool? ?? false,
      hasContent: json['has_content'] as bool? ?? false,
      isLocked: json['is_locked'] as bool? ?? false,
      lockReason: json['lock_reason'] as String?,
      status: json['status'] as String? ?? '',
      progressPercentage: json['progress_percentage'] as int? ?? 0,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }

  final int id;
  final String title;
  final int sortOrder;
  final bool hasWorkbook;
  final bool hasVideo;
  final bool hasAudio;
  final bool hasContent;
  final bool isLocked;
  final String? lockReason;
  final String status;
  final int progressPercentage;
  final String? thumbnailUrl;
}

class ModuleEbookItem {
  const ModuleEbookItem({
    required this.id,
    required this.title,
    required this.sortOrder,
    required this.previewSupported,
    this.fileName,
    this.previewMessage,
    this.mimeType,
    this.downloadUrl,
  });

  factory ModuleEbookItem.fromJson(Map<String, dynamic> json) {
    return ModuleEbookItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      sortOrder: json['sort_order'] as int? ?? 0,
      fileName: json['file_name'] as String?,
      previewSupported: json['preview_supported'] as bool? ?? false,
      previewMessage: json['preview_message'] as String?,
      mimeType: json['mime_type'] as String?,
      downloadUrl: json['download_url'] as String?,
    );
  }

  final int id;
  final String title;
  final int sortOrder;
  final String? fileName;
  final bool previewSupported;
  final String? previewMessage;
  final String? mimeType;
  final String? downloadUrl;
}

class ModuleCertificateItem {
  const ModuleCertificateItem({
    required this.id,
    required this.type,
    required this.typeLabel,
    this.fileName,
    this.generatedAt,
    this.generatedBy,
    this.downloadUrl,
  });

  factory ModuleCertificateItem.fromJson(Map<String, dynamic> json) {
    return ModuleCertificateItem(
      id: json['id'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      typeLabel: json['type_label'] as String? ?? '',
      fileName: json['file_name'] as String?,
      generatedAt: json['generated_at'] as String?,
      generatedBy: json['generated_by'] as String?,
      downloadUrl: json['download_url'] as String?,
    );
  }

  final int id;
  final String type;
  final String typeLabel;
  final String? fileName;
  final String? generatedAt;
  final String? generatedBy;
  final String? downloadUrl;
}

class ModuleVideoLecturerItem {
  const ModuleVideoLecturerItem({
    required this.id,
    required this.title,
    required this.slug,
    required this.index,
    required this.status,
    this.description,
    this.thumbnailUrl,
  });

  factory ModuleVideoLecturerItem.fromJson(Map<String, dynamic> json) {
    return ModuleVideoLecturerItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      slug: json['url_slug'] as String? ?? '',
      description: json['description'] as String?,
      index: json['index'] as int? ?? 0,
      status: json['status'] as String? ?? 'unavailable',
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }

  final int id;
  final String title;
  final String slug;
  final String? description;
  final int index;
  final String status;
  final String? thumbnailUrl;
}

class ModuleDetail {
  const ModuleDetail({
    required this.id,
    required this.title,
    required this.slug,
    required this.sortOrder,
    required this.lessonCount,
    required this.assignmentsCount,
    required this.completedLessons,
    required this.progressPercentage,
    required this.showProgress,
    required this.status,
    required this.isVisible,
    required this.isComplete,
    required this.moduleType,
    required this.certificateEnabled,
    required this.ebookEnabled,
    required this.ebooks,
    required this.certificates,
    required this.lessons,
    required this.assignments,
    required this.videoLecturers,
    required this.viewTypes, // Field Baru
    required this.primaryCtaLabel, // Field Baru
    required this.primaryCtaUrl, // Field Baru
    required this.primaryCtaKind, // Field Baru
    this.description,
    this.thumbnailUrl,
  });

  factory ModuleDetail.fromJson(Map<String, dynamic> json) {
    final rawEbooks = json['ebooks'] as List<dynamic>? ?? const [];
    final rawCertificates = json['certificates'] as List<dynamic>? ?? const [];
    final rawLessons = json['lessons'] as List<dynamic>? ?? const [];
    final rawAssignments = json['assignments'] as List<dynamic>? ?? const [];
    final rawVideoLecturers = json['video_lecturers'] as List<dynamic>? ?? const [];

    return ModuleDetail(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      lessonCount: json['lesson_count'] as int? ?? 0,
      assignmentsCount: json['assignments_count'] as int? ?? 0,
      completedLessons: json['completed_lessons'] as int? ?? 0,
      progressPercentage: json['progress_percentage'] as int? ?? 0,
      showProgress: json['show_progress'] as bool? ?? false,
      status: json['status'] as String? ?? '',
      isVisible: json['is_visible'] as bool? ?? false,
      isComplete: json['is_complete'] as bool? ?? false,
      moduleType: moduleContentTypeFromJson(json['module_type'] as String?),
      certificateEnabled: json['certificate_enabled'] as bool? ?? false,
      ebookEnabled: json['ebook_enabled'] as bool? ?? false,
      thumbnailUrl: json['thumbnail_url'] as String?,

      // Mapping field baru
      viewTypes: List<String>.from(json['view_types'] ?? []),
      primaryCtaLabel: json['primary_cta_label'] as String?,
      primaryCtaUrl: json['primary_cta_url'] as String?,
      primaryCtaKind: json['primary_cta_kind'] as String?,

      ebooks: rawEbooks
          .map((ebook) => ModuleEbookItem.fromJson(ebook as Map<String, dynamic>))
          .toList(),
      certificates: rawCertificates
          .map((cert) => ModuleCertificateItem.fromJson(cert as Map<String, dynamic>))
          .toList(),
      lessons: rawLessons
          .map((lesson) => ModuleLesson.fromJson(lesson as Map<String, dynamic>))
          .toList(),
      assignments: rawAssignments,
      videoLecturers: rawVideoLecturers
          .map((v) => ModuleVideoLecturerItem.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  final int id;
  final String title;
  final String slug;
  final String? description;
  final int sortOrder;
  final int lessonCount;
  final int assignmentsCount;
  final int completedLessons;
  final int progressPercentage;
  final bool showProgress;
  final String status;
  final bool isVisible;
  final bool isComplete;
  final ModuleContentType moduleType;
  final bool certificateEnabled;
  final bool ebookEnabled;
  final String? thumbnailUrl;
  final List<ModuleEbookItem> ebooks;
  final List<ModuleCertificateItem> certificates;
  final List<ModuleLesson> lessons;
  final List<dynamic> assignments;
  final List<ModuleVideoLecturerItem> videoLecturers;

  // Field baru
  final List<String> viewTypes;
  final String? primaryCtaLabel;
  final String? primaryCtaUrl;
  final String? primaryCtaKind;
}