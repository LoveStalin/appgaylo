import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase
import '../main.dart';
import '../widgets/story_card.dart'; // Gọi StoryCard từ nhà mới của nó vào đây

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Màn hình chính vẫn là ListView cuộn được
      padding: const EdgeInsets.all(16),
      children: [
        // 1. THANH TÌM KIẾM (Giữ nguyên)
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

        // 2. MỤC NỔI BẬT (Tạm để nguyên tĩnh đã, m kết nối Firebase sau cũng được)
        Text(
          L(context, 'featured'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // Chỗ này tạm thời tao comment lại vì m vừa đổi cấu trúc StoryCard bắt buộc có title, author...
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: const [StoryCard(), StoryCard(), StoryCard()],
        // ),
        const Text(
          "Đang cập nhật truyện nổi bật...",
          style: TextStyle(color: Colors.grey),
        ),

        const SizedBox(height: 20),

        // 3. MỤC TRUYỆN MỚI (Lắp Firebase vào đây!)
        Text(
          L(context, 'new'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        // ĐÂY CHÍNH LÀ CHỖ GỌI FIREBASE
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('stories')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            // Đang tải...
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.pink),
              );
            }

            // Lỗi mạng hoặc lỗi code
            if (snapshot.hasError) {
              return Text('Lỗi: ${snapshot.error}');
            }

            // Trống trơn
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Chưa có truyện nào!'));
            }

            // Lấy dữ liệu
            final docs = snapshot.data!.docs;

            // VÌ GIAO DIỆN CỦA M LÀ DẠNG LƯỚI (3 CỘT), NÊN TAO DÙNG GRIDVIEW THAY VÌ LISTVIEW
            return GridView.builder(
              shrinkWrap:
                  true, // CỰC KỲ QUAN TRỌNG: Để GridView có thể nằm ngoan ngoãn bên trong ListView
              physics:
                  const NeverScrollableScrollPhysics(), // Tắt cuộn của GridView, cuộn chung với ListView bên ngoài
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    3, // Hiển thị 3 truyện 1 hàng giống thiết kế cũ của m
                childAspectRatio:
                    0.6, // Tỉ lệ chiều rộng / chiều cao của cái Card (Tùy chỉnh để ảnh không bị bẹp)
                crossAxisSpacing: 10, // Khoảng cách giữa các cột
                mainAxisSpacing: 10, // Khoảng cách giữa các hàng
              ),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;

                // Trả về cái StoryCard xịn xò m đã tạo trong thư mục widgets
                return StoryCard(
                  title: data['title'] ?? 'Chưa tên',
                  author: data['authorName'] ?? 'Ẩn danh',
                  coverUrl:
                      data['coverUrl'] ?? 'https://via.placeholder.com/150',
                  onTap: () {
                    debugPrint("Bấm vào truyện: ${data['title']}");
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
