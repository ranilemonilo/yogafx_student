class EbookFileInfo {
  final String? openUrl;
  final String? downloadUrl;
  final String? previewUrl;
  final String? fileName;
  final String? mimeType;
  final bool previewSupported;
  final String? previewMessage;
  final bool isAvailable;

  const EbookFileInfo({
    this.openUrl,
    this.downloadUrl,
    this.previewUrl,
    this.fileName,
    this.mimeType,
    required this.previewSupported,
    this.previewMessage,
    required this.isAvailable,
  });

  factory EbookFileInfo.fromJson(Map<String, dynamic> json) {
    return EbookFileInfo(
      openUrl: json['open_url'] as String?,
      downloadUrl: json['download_url'] as String?,
      previewUrl: json['preview_url'] as String?,
      fileName: json['file_name'] as String?,
      mimeType: json['mime_type'] as String?,
      previewSupported: json['preview_supported'] as bool? ?? false,
      previewMessage: json['preview_message'] as String?,
      isAvailable: json['is_available'] as bool? ?? false,
    );
  }
}

class EbookItem {
  final int id;
  final String title;
  final int sortOrder;
  final String? fileName;
  final String? previewUrl;
  final String? downloadUrl;
  final EbookFileInfo file;
  final bool previewSupported;
  final String? previewMessage;
  final String? mimeType;

  const EbookItem({
    required this.id,
    required this.title,
    required this.sortOrder,
    this.fileName,
    this.previewUrl,
    this.downloadUrl,
    required this.file,
    required this.previewSupported,
    this.previewMessage,
    this.mimeType,
  });

  factory EbookItem.fromJson(Map<String, dynamic> json) {
    return EbookItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      sortOrder: json['sort_order'] as int? ?? 0,
      fileName: json['file_name'] as String?,
      previewUrl: json['preview_url'] as String?,
      downloadUrl: json['download_url'] as String?,
      file: EbookFileInfo.fromJson(
        json['file'] as Map<String, dynamic>? ?? const {},
      ),
      previewSupported: json['preview_supported'] as bool? ?? false,
      previewMessage: json['preview_message'] as String?,
      mimeType: json['mime_type'] as String?,
    );
  }
}
