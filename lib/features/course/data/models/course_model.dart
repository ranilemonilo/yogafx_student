class CourseThumbnail {
  final String? url;
  final bool isAvailable;

  const CourseThumbnail({
    this.url,
    required this.isAvailable,
  });

  factory CourseThumbnail.fromJson(Map<String, dynamic> json) {
    return CourseThumbnail(
      url: json['url'] as String?,
      isAvailable: json['is_available'] as bool? ?? false,
    );
  }
}

class CourseVideo {
  final String? videoId;
  final String? hlsUrl;
  final bool isReady;
  final bool isConfigured;
  final bool isValidId;
  final bool? isFoundInLibrary;
  final String? warningMessage;

  const CourseVideo({
    this.videoId,
    this.hlsUrl,
    required this.isReady,
    required this.isConfigured,
    required this.isValidId,
    this.isFoundInLibrary,
    this.warningMessage,
  });

  factory CourseVideo.fromJson(Map<String, dynamic> json) {
    return CourseVideo(
      videoId: json['video_id'] as String?,
      hlsUrl: json['hls_url'] as String?,
      isReady: json['is_ready'] as bool? ?? false,
      isConfigured: json['is_configured'] as bool? ?? false,
      isValidId: json['is_valid_id'] as bool? ?? false,
      isFoundInLibrary: json['is_found_in_library'] as bool?,
      warningMessage: json['warning_message'] as String?,
    );
  }
}

class CourseItem {
  final int id;
  final String title;
  final String urlSlug;
  final String? description;
  final int? index;
  final String status;
  final String? thumbnailUrl;
  final CourseThumbnail thumbnail;
  final CourseVideo video;

  const CourseItem({
    required this.id,
    required this.title,
    required this.urlSlug,
    this.description,
    this.index,
    required this.status,
    this.thumbnailUrl,
    required this.thumbnail,
    required this.video,
  });

  factory CourseItem.fromJson(Map<String, dynamic> json) {
    return CourseItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      urlSlug: json['url_slug'] as String? ?? '',
      description: json['description'] as String?,
      index: json['index'] as int?,
      status: json['status'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      thumbnail: CourseThumbnail.fromJson(
        json['thumbnail'] as Map<String, dynamic>? ?? const {},
      ),
      video: CourseVideo.fromJson(
        json['video'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class CourseListData {
  final List<CourseItem> items;

  const CourseListData({required this.items});

  factory CourseListData.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return CourseListData(
      items: rawItems
          .map((item) => CourseItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
