import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/comment_model.dart';
import '../services/comment_service.dart';

class CommentsSection extends StatefulWidget {
  final String storyId;

  const CommentsSection({super.key, required this.storyId});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final CommentService _commentService = CommentService();
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _formatCreatedAt(CommentModel comment) {
    final createdAt = comment.createdAt;
    if (createdAt == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(createdAt.toDate());
  }

  String _formatUpdatedAt(CommentModel comment) {
    final updatedAt = comment.updatedAt;
    if (updatedAt == null) return '';

    final createdAt = comment.createdAt;
    if (createdAt != null && updatedAt.toDate() == createdAt.toDate()) {
      return ''; // Don't show if same as created time
    }

    return DateFormat('dd/MM/yyyy HH:mm').format(updatedAt.toDate());
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (content.isEmpty || _isSubmitting) return;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để bình luận.')),
      );
      return;
    }

    final displayName = user.displayName?.trim();
    final userName = displayName != null && displayName.isNotEmpty
        ? displayName
        : user.email?.split('@').first ?? 'Người dùng';

    setState(() => _isSubmitting = true);

    try {
      await _commentService.createComment(
        storyId: widget.storyId,
        userId: user.uid,
        userName: userName,
        userEmail: user.email ?? '',
        userPhotoUrl: user.photoURL ?? '',
        content: content,
      );

      if (!mounted) return;
      _commentController.clear();
      FocusScope.of(context).unfocus();
    } on FirebaseException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể gửi bình luận: ${error.code}')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.storyId.isEmpty) {
      return const Text('Không thể xác định truyện để tải bình luận.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bình luận',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _commentController,
          minLines: 2,
          maxLines: 4,
          maxLength: 1000,
          textInputAction: TextInputAction.newline,
          enabled: !_isSubmitting,
          decoration: InputDecoration(
            hintText: 'Viết bình luận của bạn...',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              onPressed: _isSubmitting ? null : _submitComment,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              tooltip: 'Gửi bình luận',
            ),
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<CommentModel>>(
          stream: _commentService.watchComments(widget.storyId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              final error = snapshot.error;
              debugPrint('Comment stream error: $error');

              if (error is FirebaseException &&
                  error.code == 'permission-denied') {
                return const Text(
                  'Firestore chưa cấp quyền đọc bình luận. Hãy publish Rules.',
                );
              }

              return Text('Không thể tải bình luận: $error');
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final comments = snapshot.data!;
            if (comments.isEmpty) {
              return const Text(
                'Chưa có bình luận nào. Hãy là người đầu tiên!',
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${comments.length} bình luận'),
                const SizedBox(height: 10),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: comments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final authorName = comment.authorName.isEmpty
                        ? 'Ẩn danh'
                        : comment.authorName;
                    final createdAt = _formatCreatedAt(comment);
                    final updatedAt = _formatUpdatedAt(comment);
                    final isEdited = updatedAt.isNotEmpty;

                    return Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundImage: comment.userPhotoUrl.isEmpty
                                  ? null
                                  : NetworkImage(comment.userPhotoUrl),
                              child: comment.userPhotoUrl.isEmpty
                                  ? Text(authorName[0].toUpperCase())
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        authorName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (isEdited) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: const Text(
                                            'Đã chỉnh sửa',
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (createdAt.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      createdAt,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                  if (isEdited) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Chỉnh sửa: $updatedAt',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey[600],
                                          ),
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
        ),
      ],
    );
  }
}
