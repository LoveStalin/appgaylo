import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/messages_model.dart';

class MessageService {
  CollectionReference<Map<String, dynamic>> messageCollection(
    String storyId,
    String chapterId,
  ) {
    return FirebaseFirestore.instance
        .collection("stories")
        .doc(storyId)
        .collection("chapters")
        .doc(chapterId)
        .collection("messages");
  }

  Future<void> sendMessage(
    String storyId,
    String chapterId,
    MessageModel message,
  ) async {
    await messageCollection(
      storyId,
      chapterId,
    ).doc(message.messageId).set(message.toMap());
  }

  Future<List<MessageModel>> getMessages(
    String storyId,
    String chapterId,
  ) async {
    final snapshot = await messageCollection(
      storyId,
      chapterId,
    ).orderBy("createdAt").get();

    return snapshot.docs.map((doc) {
      return MessageModel.fromMap(doc.data(), doc.id);
    }).toList();
  }

  Future<void> deleteMessage(
    String storyId,
    String chapterId,
    String messageId,
  ) async {
    await messageCollection(storyId, chapterId).doc(messageId).delete();
  }
}
