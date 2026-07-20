import 'package:flutter/material.dart';

class ChapterBottomBar extends StatelessWidget {
  const ChapterBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey)),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          ElevatedButton(onPressed: () {}, child: const Text("◀ Trước")),

          ElevatedButton(onPressed: () {}, child: const Text("Tiếp ▶")),
        ],
      ),
    );
  }
}
