import 'package:flutter/material.dart';

class StoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const StoryDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(data['title'] ?? "Chi tiết truyện")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh bìa dùng Hero để giữ hiệu ứng phóng to
            Hero(
              tag: data['title'], // Phải trùng tag với StoryCard
              child: Image.network(
                data['coverUrl'],
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              data['title'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text("Tác giả: ${data['authorName']}"),
            const SizedBox(height: 10),
            Text(data['description'] ?? "Không có mô tả."),
            const SizedBox(height: 20),
            // Hai thông tin mới
            const Divider(),
            Text("Ngày tạo: ${data['createdAt']}"),
            Text("Cập nhật cuối: ${data['updatedAt']}"),
          ],
        ),
      ),
    );
  }
}
