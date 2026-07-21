import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/comment_model.dart';

class CommentService {
  CollectionReference<Map<String, dynamic>> _commentCollection(String storyId) {
    return FirebaseFirestore.instance
        .collection('stories')
        .doc(storyId)
        .collection('comments');
  }

  Stream<List<CommentModel>> watchComments(String storyId) {
    return _commentCollection(storyId).snapshots().map((snapshot) {
      final comments = snapshot.docs
          .map((document) => CommentModel.fromMap(document.data(), document.id))
          .toList();

      // Sort by createdAt descending (newest first)
      comments.sort((first, second) {
        final firstTime = first.createdAt?.millisecondsSinceEpoch ?? 0;
        final secondTime = second.createdAt?.millisecondsSinceEpoch ?? 0;
        return secondTime.compareTo(firstTime);
      });

      return comments;
    });
  }

  Future<void> createComment({
    required String storyId,
    required String userId,
    required String userName,
    required String userEmail,
    required String userPhotoUrl,
    required String content,
  }) async {
    // Generate document ID and create the comment with full field synchronization
    final documentRef = _commentCollection(storyId).doc();
    final now = FieldValue.serverTimestamp();

    await documentRef.set({
      'commentId': documentRef.id,
      'storyId': storyId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future<void> updateComment({
    required String storyId,
    required String commentId,
    required String content,
  }) async {
    await _commentCollection(storyId).doc(commentId).update({
      'content': content,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteComment({
    required String storyId,
    required String commentId,
  }) async {
    await _commentCollection(storyId).doc(commentId).delete();
  }

  Future<CommentModel?> getComment({
    required String storyId,
    required String commentId,
  }) async {
    try {
      final doc = await _commentCollection(storyId).doc(commentId).get();
      if (!doc.exists) return null;
      return CommentModel.fromMap(doc.data() ?? {}, doc.id);
    } catch (e) {
      debugPrint('Error fetching comment: $e');
      return null;
    }
  }
}
