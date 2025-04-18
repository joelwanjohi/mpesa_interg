class Comment {
  final String id;
  final String noticeId;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime timestamp;
  
  Comment({
    required this.id,
    required this.noticeId,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.timestamp,
  });
  
  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'noticeId': noticeId,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'timestamp': timestamp,
    };
  }
  
  // Create from Firestore document
  factory Comment.fromMap(String id, Map<String, dynamic> map) {
    return Comment(
      id: id,
      noticeId: map['noticeId'] ?? '',
      content: map['content'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      timestamp: (map['timestamp'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
}