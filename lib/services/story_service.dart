import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/story_model.dart';

class StoryService {
  final CollectionReference<Map<String, dynamic>> _storyCollection =
      FirebaseFirestore.instance.collection("stories");

  // Đăng truyện
  Future<void> createStory(StoryModel story) async {
    await _storyCollection.doc(story.storyId).set(story.toMap());
  }

  // Lấy toàn bộ truyện
  Future<List<StoryModel>> getStories() async {
    final snapshot = await _storyCollection.get();

    return snapshot.docs.map((doc) {
      return StoryModel.fromMap(doc.data(), doc.id);
    }).toList();
  }

  // Lấy 1 truyện theo ID
  Future<StoryModel?> getStoryById(String storyId) async {
    final doc = await _storyCollection.doc(storyId).get();

    if (!doc.exists) {
      return null;
    }

    return StoryModel.fromMap(doc.data()!, doc.id);
  }

  // Update truyện
  Future<void> updateStory(StoryModel story) async {
    await _storyCollection.doc(story.storyId).update(story.toMap());
  }

  // Xóa truyện
  Future<void> deleteStory(String storyId) async {
    await _storyCollection.doc(storyId).delete();
  }

  // Tăng lượt xem
  Future<void> increaseView(String storyId) async {
    await _storyCollection.doc(storyId).update({
      "views": FieldValue.increment(1),
    });
  }

  // Tăng lượt thích
  Future<void> increaseLike(String storyId) async {
    await _storyCollection.doc(storyId).update({
      "likes": FieldValue.increment(1),
    });
  }

  // Giảm lượt thích
  Future<void> decreaseLike(String storyId) async {
    await _storyCollection.doc(storyId).update({
      "likes": FieldValue.increment(-1),
    });
  }

  // Tăng follower
  Future<void> increaseFollower(String storyId) async {
    await _storyCollection.doc(storyId).update({
      "followers": FieldValue.increment(1),
    });
  }

  // Giảm follower
  Future<void> decreaseFollower(String storyId) async {
    await _storyCollection.doc(storyId).update({
      "followers": FieldValue.increment(-1),
    });
  }

  // Tăng số chapter
  Future<void> increaseChapterCount(String storyId) async {
    await _storyCollection.doc(storyId).update({
      "chapterCount": FieldValue.increment(1),
    });
  }

  // Giảm số chapter
  Future<void> decreaseChapterCount(String storyId) async {
    await _storyCollection.doc(storyId).update({
      "chapterCount": FieldValue.increment(-1),
    });
  }
}
