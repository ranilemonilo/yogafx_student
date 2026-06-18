class AssignmentModuleInfo {
  final int? id;
  final String? title;
  final String? slug;
  final String? status;

  const AssignmentModuleInfo({
    this.id,
    this.title,
    this.slug,
    this.status,
  });

  factory AssignmentModuleInfo.fromJson(Map<String, dynamic> json) {
    return AssignmentModuleInfo(
      id: json['id'] as int?,
      title: json['title'] as String?,
      slug: json['slug'] as String?,
      status: json['status'] as String?,
    );
  }
}

class AssignmentSubmissionInfo {
  final int id;
  final String status;
  final String? feedback;
  final String? submittedAt;
  final String? reviewedAt;
  final String? videoUrl;

  const AssignmentSubmissionInfo({
    required this.id,
    required this.status,
    this.feedback,
    this.submittedAt,
    this.reviewedAt,
    this.videoUrl,
  });

  factory AssignmentSubmissionInfo.fromJson(Map<String, dynamic> json) {
    return AssignmentSubmissionInfo(
      id: json['id'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      feedback: json['feedback'] as String?,
      submittedAt: json['submitted_at'] as String?,
      reviewedAt: json['reviewed_at'] as String?,
      videoUrl: json['video_url'] as String?,
    );
  }
}

class AssignmentUploadConstraints {
  final int videoMaxSizeBytes;
  final String videoMaxSizeLabel;
  final List<String> acceptedExtensions;

  const AssignmentUploadConstraints({
    required this.videoMaxSizeBytes,
    required this.videoMaxSizeLabel,
    required this.acceptedExtensions,
  });

  factory AssignmentUploadConstraints.fromJson(Map<String, dynamic> json) {
    final rawExtensions =
        json['accepted_extensions'] as List<dynamic>? ?? const [];
    return AssignmentUploadConstraints(
      videoMaxSizeBytes: json['video_max_size_bytes'] as int? ?? 0,
      videoMaxSizeLabel: json['video_max_size_label'] as String? ?? '',
      acceptedExtensions:
          rawExtensions.map((item) => item.toString()).toList(),
    );
  }
}

class AssignmentDetail {
  final int id;
  final String title;
  final String? description;
  final int? sortOrder;
  final String? status;
  final bool isRequired;
  final bool isLocked;
  final String? lockReason;
  final bool canSubmit;
  final AssignmentModuleInfo module;
  final AssignmentSubmissionInfo? submission;
  final AssignmentUploadConstraints? uploadConstraints;

  const AssignmentDetail({
    required this.id,
    required this.title,
    this.description,
    this.sortOrder,
    this.status,
    required this.isRequired,
    required this.isLocked,
    this.lockReason,
    required this.canSubmit,
    required this.module,
    this.submission,
    this.uploadConstraints,
  });

  factory AssignmentDetail.fromJson(Map<String, dynamic> json) {
    return AssignmentDetail(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      sortOrder: json['sort_order'] as int?,
      status: json['status'] as String?,
      isRequired: json['is_required'] as bool? ?? false,
      isLocked: json['is_locked'] as bool? ?? false,
      lockReason: json['lock_reason'] as String?,
      canSubmit: json['can_submit'] as bool? ?? false,
      module: AssignmentModuleInfo.fromJson(
        json['module'] as Map<String, dynamic>? ?? const {},
      ),
      submission: json['submission'] == null
          ? null
          : AssignmentSubmissionInfo.fromJson(
              json['submission'] as Map<String, dynamic>,
            ),
      uploadConstraints: json['upload_constraints'] == null
          ? null
          : AssignmentUploadConstraints.fromJson(
              json['upload_constraints'] as Map<String, dynamic>,
            ),
    );
  }
}

class AssignmentSubmitResponse {
  final int assignmentId;
  final AssignmentSubmissionInfo submission;

  const AssignmentSubmitResponse({
    required this.assignmentId,
    required this.submission,
  });

  factory AssignmentSubmitResponse.fromJson(Map<String, dynamic> json) {
    return AssignmentSubmitResponse(
      assignmentId: json['assignment_id'] as int? ?? 0,
      submission: AssignmentSubmissionInfo.fromJson(
        json['submission'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}
