import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String storyId;
  final String userId;
  final String authorName;
  final String userEmail;
  final String userPhotoUrl;
  final String content;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const CommentModel({
    required this.commentId,
    required this.storyId,
    required this.userId,
    required this.authorName,
    required this.userEmail,
    required this.userPhotoUrl,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map, String documentId) {
    final createdAt = map['createdAt'];
    final updatedAt = map['updatedAt'];

    return CommentModel(
      commentId: documentId,
      storyId: _safeToString(map['storyId']),
      userId: _safeToString(map['userId']),
      authorName: _safeToString(
        map['userName'] ?? map['authorName'] ?? map['author'],
      ),
      userEmail: _safeToString(map['userEmail']),
      userPhotoUrl: _safeToString(map['userPhotoUrl']),
      content: _safeToString(map['content'] ?? map['text'] ?? map['comment']),
      createdAt: createdAt is Timestamp ? createdAt : null,
      updatedAt: updatedAt is Timestamp ? updatedAt : null,
    );
  }

  static String _safeToString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  // Convert model to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'storyId': storyId,
      'userId': userId,
      'userName': authorName,
      'userEmail': userEmail,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
