import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const StoryDetailScreen({super.key, required this.data});

  String formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "Không rõ";

    if (timestamp is Timestamp) {
      return DateFormat("dd/MM/yyyy HH:mm").format(timestamp.toDate());
    }

    return timestamp.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(data['title'] ?? "Chi tiết truyện")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Hero(
              tag: data['title'],

              child: Image.network(
                data['coverUrl'],
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              data['title'] ?? "",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              "Tác giả: ${data['authorName']}",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            Text(
              data['description'] ?? "",
              style: const TextStyle(fontSize: 17),
            ),

            const SizedBox(height: 20),

            const Divider(),

            Text("Ngày tạo: ${formatTimestamp(data['createdAt'])}"),

            Text("Cập nhật cuối: ${formatTimestamp(data['updatedAt'])}"),

            Text("Số chương: ${data['chapterCount']}"),

            Text("Lượt xem: ${data['views']}"),

            Text("Lượt thích: ${data['likes']}"),

            Text("Follower: ${data['followers']}"),

            Text("Bình luận: ${data['comment']}"),

            Text("Trạng thái: ${data['status']}"),

            Text("Thể loại: ${data['genre']}"),

            const SizedBox(height: 30),

            ElevatedButton(onPressed: () {}, child: const Text("Đọc truyện")),
          ],
        ),
      ),
    );
  }
}
