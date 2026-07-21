import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/comment_model.dart';

class CommentService {
  Stream<List<CommentModel>> watchComments(String storyId) {
    return FirebaseFirestore.instance
        .collection('stories')
        .doc(storyId)
        .collection('comments')
        .snapshots()
        .map((snapshot) {
          final comments = snapshot.docs
              .map(
                (document) =>
                    CommentModel.fromMap(document.data(), document.id),
              )
              .toList();

          comments.sort((first, second) {
            final firstTime = first.createdAt?.millisecondsSinceEpoch ?? 0;
            final secondTime = second.createdAt?.millisecondsSinceEpoch ?? 0;
            return secondTime.compareTo(firstTime);
          });

          return comments;
        });
  }
}
