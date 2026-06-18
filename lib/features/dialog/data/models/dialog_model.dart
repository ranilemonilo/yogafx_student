class DialogItem {
  final String key;
  final String title;
  final String content;
  final bool hasContent;

  const DialogItem({
    required this.key,
    required this.title,
    required this.content,
    required this.hasContent,
  });

  factory DialogItem.fromJson(Map<String, dynamic> json) {
    return DialogItem(
      key: json['key'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      hasContent: json['has_content'] as bool? ?? false,
    );
  }
}

class DialogListData {
  final List<DialogItem> items;

  const DialogListData({required this.items});

  factory DialogListData.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return DialogListData(
      items: rawItems
          .map((item) => DialogItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
