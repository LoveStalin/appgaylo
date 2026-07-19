import 'package:cloud_firestore/cloud_firestore.dart';

class ChapterModel {
  final String chapterId;
  final String storyId;

  final String title;

  // paragraph | chat
  final String type;

  // Nội dung chapter
  final dynamic content;

  final int views;
  final int likes;

  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  ChapterModel({
    required this.chapterId,
    required this.storyId,
    required this.title,
    required this.type,
    required this.content,
    required this.views,
    required this.likes,
    this.createdAt,
    this.updatedAt,
  });

  factory ChapterModel.fromMap(
    Map<String, dynamic> map,
    String docId,
    String storyId,
  ) {
    return ChapterModel(
      chapterId: docId,
      storyId: storyId,

      title: map["title"] ?? "",

      type: map["type"] ?? "paragraph",

      content: map["content"],

      views: map["views"] ?? 0,
      likes: map["likes"] ?? 0,

      createdAt: map["createdAt"],
      updatedAt: map["updatedAt"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,

      "type": type,

      "content": content,

      "views": views,
      "likes": likes,

      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}
