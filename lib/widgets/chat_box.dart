import 'package:flutter/material.dart';

import '../models/messages_model.dart';

class ChatBox extends StatelessWidget {
  final MessageModel message;

  const ChatBox({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // System Message
    if (message.type == "system") {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Text(
            message.text,
            style: const TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    // Center Message (ví dụ ngày tháng)
    if (message.senderType == "center") {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message.text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    final bool isRight = message.senderType == "right";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        mainAxisAlignment: isRight
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,

        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 280),

            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: isRight ? Colors.blue : Colors.grey.shade300,

              borderRadius: BorderRadius.circular(16),
            ),

            child: Column(
              crossAxisAlignment: isRight
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,

              children: [
                Text(
                  message.sender,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isRight ? Colors.white : Colors.black,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  message.text,
                  style: TextStyle(
                    color: isRight ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
