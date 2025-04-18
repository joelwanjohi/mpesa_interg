// lib/models/notice.dart

class Notice {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final String authorId;
  final String authorName;
  final List<String> tags;
  final bool isImportant;
  final int viewCount;
  
  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.authorId,
    required this.authorName,
    this.tags = const [],
    this.isImportant = false,
    this.viewCount = 0,
  });
  
  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'timestamp': timestamp,
      'authorId': authorId,
      'authorName': authorName,
      'tags': tags,
      'isImportant': isImportant,
      'viewCount': viewCount,
    };
  }
  
  // Create from Firestore document
  factory Notice.fromMap(Map<String, dynamic> map, String id) {
    return Notice(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as dynamic)?.toDate() ?? DateTime.now(),
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      isImportant: map['isImportant'] ?? false,
      viewCount: map['viewCount'] ?? 0,
    );
  }
  
  // Create a copy with updated fields
  Notice copyWith({
    String? title,
    String? content,
    DateTime? timestamp,
    String? authorId,
    String? authorName,
    List<String>? tags,
    bool? isImportant,
    int? viewCount,
  }) {
    return Notice(
      id: this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      tags: tags ?? this.tags,
      isImportant: isImportant ?? this.isImportant,
      viewCount: viewCount ?? this.viewCount,
    );
  }
}