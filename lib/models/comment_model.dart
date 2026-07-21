import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String storyId;
  final String authorName;
  final String content;
  final Timestamp? createdAt;

  const CommentModel({
    required this.commentId,
    required this.storyId,
    required this.authorName,
    required this.content,
    this.createdAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map, String documentId) {
    final createdAt = map['createdAt'];

    return CommentModel(
      commentId: documentId,
      storyId: (map['storyId'] ?? '').toString(),
      authorName: (map['userName'] ?? map['authorName'] ?? map['author'] ?? '')
          .toString(),
      content: (map['content'] ?? map['text'] ?? map['comment'] ?? '')
          .toString(),
      createdAt: createdAt is Timestamp ? createdAt : null,
    );
  }
}
