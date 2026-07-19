import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  final String storyId;
  final String authorId;

  final String title;
  final String description;
  final String coverUrl;

  final List<String> genre;

  final String status;
  final String storyType;

  final int likes;
  final int views;
  final int comments;
  final int chapterCount;
  final int followers;

  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  StoryModel({
    required this.storyId,
    required this.authorId,
    required this.title,
    required this.description,
    required this.coverUrl,
    required this.genre,
    required this.status,
    required this.storyType,
    required this.likes,
    required this.views,
    required this.comments,
    required this.chapterCount,
    required this.followers,
    this.createdAt,
    this.updatedAt,
  });

  factory StoryModel.fromMap(Map<String, dynamic> map, String docId) {
    return StoryModel(
      storyId: docId,
      authorId: map['authorId'] ?? '',

      title: map['title'] ?? '',
      description: map['description'] ?? '',
      coverUrl: map['coverUrl'] ?? '',

      genre: List<String>.from(map['genre'] ?? []),

      status: map['status'] ?? '',
      storyType: map['storyType'] ?? '',

      likes: map['likes'] ?? 0,
      views: map['views'] ?? 0,
      comments: map['comments'] ?? 0,
      chapterCount: map['chapterCount'] ?? 0,
      followers: map['followers'] ?? 0,

      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,

      'title': title,
      'description': description,
      'coverUrl': coverUrl,

      'genre': genre,

      'status': status,
      'storyType': storyType,

      'likes': likes,
      'views': views,
      'comments': comments,
      'chapterCount': chapterCount,
      'followers': followers,

      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
