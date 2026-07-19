import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chapter_model.dart';

class ChapterService {
  CollectionReference<Map<String, dynamic>> chapterCollection(String storyId) {
    return FirebaseFirestore.instance
        .collection("stories")
        .doc(storyId)
        .collection("chapters");
  }

  Future<void> createChapter(ChapterModel chapter) async {
    await chapterCollection(
      chapter.storyId,
    ).doc(chapter.chapterId).set(chapter.toMap());
  }

  Future<List<ChapterModel>> getChapters(String storyId) async {
    final snapshot = await chapterCollection(
      storyId,
    ).orderBy("createdAt").get();

    return snapshot.docs.map((doc) {
      return ChapterModel.fromMap(doc.data(), doc.id, storyId);
    }).toList();
  }

  Future<ChapterModel?> getChapter(String storyId, String chapterId) async {
    final doc = await chapterCollection(storyId).doc(chapterId).get();

    if (!doc.exists) {
      return null;
    }

    return ChapterModel.fromMap(doc.data()!, doc.id, storyId);
  }

  Future<void> updateChapter(ChapterModel chapter) async {
    await chapterCollection(
      chapter.storyId,
    ).doc(chapter.chapterId).update(chapter.toMap());
  }

  Future<void> deleteChapter(String storyId, String chapterId) async {
    await chapterCollection(storyId).doc(chapterId).delete();
  }

  Future<void> increaseView(String storyId, String chapterId) async {
    await chapterCollection(
      storyId,
    ).doc(chapterId).update({"views": FieldValue.increment(1)});
  }
}
