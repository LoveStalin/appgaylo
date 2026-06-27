import 'package:flutter/material.dart';

class StoryCard extends StatelessWidget {
  final String title;
  final String author;
  final String coverUrl;
  final VoidCallback onTap; // Hàm để bắt sự kiện khi m bấm vào truyện

  const StoryCard({
    super.key,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Bọc GestureDetector bên ngoài để cái Card này có thể bấm được
      onTap: onTap,
      child: Hero(
        tag:
            title, // Tag này phải trùng với Hero trong StoryDetailScreen để giữ hiệu ứng phóng to
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Bọc trong Expanded để ảnh bìa tự động co giãn vừa vặn với ô GridView
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.pink[100], // Màu nền hồng đặc trưng của m
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  // Hiển thị ảnh bìa kéo từ Firebase về
                  child: Image.network(
                    coverUrl,
                    fit: BoxFit.cover, // Cắt cúp ảnh cho vừa khít khung
                    // NẾU TRUYỆN CHƯA CÓ ẢNH HOẶC LINK ẢNH LỖI:
                    // Nó sẽ tự động fallback về cái UI icon cuốn sách cũ của m!
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.book,
                          size: 40,
                          color: Colors.black54,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),

            // Hiển thị tên truyện thật (không cứng chữ "Tên truyện" nữa)
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
              maxLines: 1, // Giới hạn 1 dòng
              overflow: TextOverflow.ellipsis, // Dài quá thì hiện dấu 3 chấm...
            ),

            // (Tùy chọn) M có thể mở comment dòng dưới để hiện thêm tên tác giả nếu muốn
            Text(
              author,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
