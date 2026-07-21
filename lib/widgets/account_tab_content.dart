import 'package:flutter/material.dart';

class AccountTabContent extends StatelessWidget {
  final int tabIndex;
  final VoidCallback onWriteButtonPressed;

  const AccountTabContent({
    super.key,
    required this.tabIndex,
    required this.onWriteButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 240, child: Center(child: _buildContent()));
  }

  Widget _buildContent() {
    if (tabIndex == 0) {
      // Posts
      return _buildEmptyState('Bạn chưa viết truyện nào');
    } else if (tabIndex == 1) {
      // Drafts - show write button
      return ElevatedButton(
        onPressed: onWriteButtonPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: const Text('Thử viết truyện'),
      );
    } else {
      // Likes
      return _buildEmptyState('Bạn chưa viết truyện nào');
    }
  }

  Widget _buildEmptyState(String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.image, size: 56, color: Colors.grey),
        const SizedBox(height: 12),
        Text(message, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}
