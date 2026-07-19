import 'package:flutter/material.dart';

import '../services/story_service.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  Future<void> testGetStories() async {
    final stories = await StoryService().getStories();

    debugPrint("========== STORY TEST ==========");

    for (final story in stories) {
      debugPrint(story.title);
    }

    debugPrint("Tổng số truyện: ${stories.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Developer Screen")),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          ElevatedButton(
            onPressed: testGetStories,
            child: const Text("Test StoryService"),
          ),
        ],
      ),
    );
  }
}
