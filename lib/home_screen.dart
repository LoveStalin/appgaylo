import 'package:flutter/material.dart';
import 'main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: L(context, 'search_hint'),
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.pink[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          L(context, 'featured'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [StoryCard(), StoryCard(), StoryCard()],
        ),
        const SizedBox(height: 20),
        Text(
          L(context, 'new'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [StoryCard(), StoryCard(), StoryCard()],
        ),
      ],
    );
  }
}

class StoryCard extends StatelessWidget {
  const StoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.pink[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.book, size: 40),
        ),
        const SizedBox(height: 5),
        const Text("Tên truyện", overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
