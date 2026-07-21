import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/comment_model.dart';
import '../services/comment_service.dart';

class CommentsSection extends StatelessWidget {
  final String storyId;

  const CommentsSection({super.key, required this.storyId});

  String _formatCreatedAt(CommentModel comment) {
    final createdAt = comment.createdAt;
    if (createdAt == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(createdAt.toDate());
  }

  @override
  Widget build(BuildContext context) {
    if (storyId.isEmpty) {
      return const Text('Khong the xac dinh truyen de tai binh luan.');
    }

    return StreamBuilder<List<CommentModel>>(
      stream: CommentService().watchComments(storyId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error;
          debugPrint('Comment stream error: $error');

          if (error is FirebaseException && error.code == 'permission-denied') {
            return const Text(
              'Firestore chua cap quyen doc binh luan. Hay publish Rules.',
            );
          }

          return Text('Khong the tai binh luan: $error');
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final comments = snapshot.data!;
        if (comments.isEmpty) {
          return const Text('Chua co binh luan nao.');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Binh luan (${comments.length})',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final comment = comments[index];
                final authorName = comment.authorName.isEmpty
                    ? 'An danh'
                    : comment.authorName;
                final createdAt = _formatCreatedAt(comment);

                return Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(child: Text(authorName[0].toUpperCase())),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authorName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (createdAt.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  createdAt,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                              const SizedBox(height: 6),
                              Text(comment.content),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
