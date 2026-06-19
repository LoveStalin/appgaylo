import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isEmailVerified = false;
  bool _canResendEmail = true;
  Timer? _timer;
  int _resendCountdown = 60;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();

    // 1. Kiểm tra xem user hiện tại đã xác thực chưa
    _isEmailVerified =
        FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!_isEmailVerified) {
      // 2. Nếu chưa xác thực, cứ mỗi 3 giây sẽ kiểm tra lại 1 lần
      _timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // Hàm tải lại dữ liệu từ Firebase để kiểm tra xem User đã bấm vào Link chưa
  Future<void> _checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user
          .reload(); // Bắt buộc phải reload để cập nhật trạng thái mới nhất từ server

      setState(() {
        _isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      });

      if (_isEmailVerified) {
        _timer?.cancel(); // Tắt bộ đếm 3 giây khi đã xác thực thành công
        _showMessage("Xác thực Email thành công!");

        // Chuyển thẳng user vào màn hình chính (HomePage) và xóa các màn hình trước đó
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    }
  }

  // Hàm gửi lại Email xác thực nếu user yêu cầu
  Future<void> _resendVerificationEmail() async {
    if (!_canResendEmail) return;

    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      _showMessage("Đã gửi lại link kích hoạt vào email của bạn!");

      setState(() {
        _canResendEmail = false;
        _resendCountdown = 60;
      });

      // Đếm ngược 60s trước khi cho bấm lại nút gửi
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_resendCountdown > 0) {
          setState(() {
            _resendCountdown--;
          });
        } else {
          setState(() {
            _canResendEmail = true;
          });
          _countdownTimer?.cancel();
        }
      });
    } catch (e) {
      _showMessage("Lỗi gửi lại mail: ${e.toString()}");
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kích hoạt tài khoản"),
        backgroundColor: isDark ? Colors.grey[850] : Colors.pink[100],
        centerTitle: true,
        // Chặn không cho user bấm nút Back quay lại khi chưa xác thực xong
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.mail_lock_outlined, size: 100, color: Colors.pink),
            const SizedBox(height: 24),
            const Text(
              "Xác thực Email của bạn",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(
                    text: "Một đường link kích hoạt đã được gửi tới email:\n",
                  ),
                  TextSpan(
                    text: widget.email,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const TextSpan(
                    text:
                        "\n\nVui lòng mở hộp thư đến (hoặc hộp thư rác) và bấm vào link để kích hoạt tài khoản của bạn.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Vòng xoay tiến trình hiển thị cho user biết app đang đợi họ bấm link
            const CircularProgressIndicator(color: Colors.pink),
            const SizedBox(height: 16),
            Text(
              "Đang chờ bạn bấm link kích hoạt...",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 48),

            // Nút bấm gửi lại mail
            _canResendEmail
                ? ElevatedButton.icon(
                    onPressed: _resendVerificationEmail,
                    icon: const Icon(Icons.replay, color: Colors.white),
                    label: const Text(
                      "Gửi lại Email kích hoạt",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                : Text(
                    "Bạn có thể yêu cầu gửi lại sau $_resendCountdown giây",
                    style: const TextStyle(color: Colors.grey),
                  ),

            TextButton(
              onPressed: () async {
                // Nếu muốn hủy quá trình đăng ký, đăng xuất tài khoản chưa kích hoạt này ra
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                "Hủy và quay lại",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
