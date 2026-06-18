class CertRequirement {
  final String key;
  final String label;
  final int completed;
  final int total;
  final bool isComplete;
  final String status;

  const CertRequirement({
    required this.key,
    required this.label,
    required this.completed,
    required this.total,
    required this.isComplete,
    required this.status,
  });

  factory CertRequirement.fromJson(Map<String, dynamic> json) {
    return CertRequirement(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      completed: json['completed'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      isComplete: json['is_complete'] as bool? ?? false,
      status: json['status'] as String? ?? '',
    );
  }
}

class CertTier {
  final int id;
  final String name;
  final String slug;

  const CertTier({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory CertTier.fromJson(Map<String, dynamic> json) {
    return CertTier(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}

class CertSummary {
  final bool learningEligible;
  final bool hasRequiredName;
  final String? message;
  final CertTier? tier;
  final List<String> availableTypes;
  final List<CertRequirement> requirements;
  final int generatedCount;

  const CertSummary({
    required this.learningEligible,
    required this.hasRequiredName,
    this.message,
    this.tier,
    required this.availableTypes,
    required this.requirements,
    required this.generatedCount,
  });

  factory CertSummary.fromJson(Map<String, dynamic> json) {
    final rawRequirements = json['requirements'] as List<dynamic>? ?? const [];
    final rawTypes = json['available_types'] as List<dynamic>? ?? const [];
    return CertSummary(
      learningEligible: json['learning_eligible'] as bool? ?? false,
      hasRequiredName: json['has_required_name'] as bool? ?? false,
      message: json['message'] as String?,
      tier: json['tier'] == null
          ? null
          : CertTier.fromJson(json['tier'] as Map<String, dynamic>),
      availableTypes: rawTypes.map((item) => item.toString()).toList(),
      requirements: rawRequirements
          .map((item) => CertRequirement.fromJson(item as Map<String, dynamic>))
          .toList(),
      generatedCount: json['generated_count'] as int? ?? 0,
    );
  }
}

class CertificateFileInfo {
  final String? openUrl;
  final String? downloadUrl;
  final String? previewUrl;
  final String? fileName;
  final String? mimeType;
  final bool previewSupported;
  final bool isAvailable;

  const CertificateFileInfo({
    this.openUrl,
    this.downloadUrl,
    this.previewUrl,
    this.fileName,
    this.mimeType,
    required this.previewSupported,
    required this.isAvailable,
  });

  factory CertificateFileInfo.fromJson(Map<String, dynamic> json) {
    return CertificateFileInfo(
      openUrl: json['open_url'] as String?,
      downloadUrl: json['download_url'] as String?,
      previewUrl: json['preview_url'] as String?,
      fileName: json['file_name'] as String?,
      mimeType: json['mime_type'] as String?,
      previewSupported: json['preview_supported'] as bool? ?? false,
      isAvailable: json['is_available'] as bool? ?? false,
    );
  }
}

class CertificateItem {
  final int id;
  final String type;
  final String typeLabel;
  final String? fileName;
  final int? version;
  final String? generatedAt;
  final String? generatedBy;
  final String? downloadUrl;
  final String? openUrl;
  final CertificateFileInfo file;

  const CertificateItem({
    required this.id,
    required this.type,
    required this.typeLabel,
    this.fileName,
    this.version,
    this.generatedAt,
    this.generatedBy,
    this.downloadUrl,
    this.openUrl,
    required this.file,
  });

  factory CertificateItem.fromJson(Map<String, dynamic> json) {
    return CertificateItem(
      id: json['id'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      typeLabel: json['type_label'] as String? ?? '',
      fileName: json['file_name'] as String?,
      version: json['version'] as int?,
      generatedAt: json['generated_at'] as String?,
      generatedBy: json['generated_by'] as String?,
      downloadUrl: json['download_url'] as String?,
      openUrl: json['open_url'] as String?,
      file: CertificateFileInfo.fromJson(
        json['file'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class CertificateListData {
  final CertSummary summary;
  final List<CertificateItem> items;

  const CertificateListData({
    required this.summary,
    required this.items,
  });

  factory CertificateListData.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return CertificateListData(
      summary: CertSummary.fromJson(
        json['summary'] as Map<String, dynamic>? ?? const {},
      ),
      items: rawItems
          .map((item) => CertificateItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
