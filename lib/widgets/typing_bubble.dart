import 'package:flutter/material.dart';

class TypingBubble extends StatelessWidget {
  final bool isRight;

  const TypingBubble({super.key, required this.isRight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        mainAxisAlignment: isRight
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,

        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),

            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(18),
            ),

            child: const Text(
              "● ● ●",
              style: TextStyle(fontSize: 18, letterSpacing: 2),
            ),
          ),
        ],
      ),
    );
  }
}
