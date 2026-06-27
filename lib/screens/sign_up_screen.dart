import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import 'email_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signUpWithEmail() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('Vui lòng nhập đầy đủ tất cả các trường dữ liệu');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Mật khẩu xác nhận không khớp nhau');
      return;
    }

    if (password.length < 6) {
      _showMessage('Mật khẩu phải chứa ít nhất 6 ký tự');
      return;
    }

    try {
      setState(() => _loading = true);

      // 1. Tạo tài khoản trên Firebase Auth
      final UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. Cập nhật Họ và tên (displayName) vào Profile của User
      await credential.user?.updateDisplayName(name);

      // 3. LOGIC MỚI Thêm vào: Gửi link kích hoạt vào email vừa đăng ký
      await credential.user?.sendEmailVerification();

      _showMessage(
        'Đăng ký thành công! Vui lòng kiểm tra email để kích hoạt tài khoản.',
      );

      // 4. LOGIC MỚI Thêm vào: Chuyển hướng sang màn hình chờ kích hoạt thay vì gọi hàm .pop() như cũ
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(email: email),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Bắt các lỗi phổ biến từ Firebase (ví dụ: email đã tồn tại, sai định dạng...)
      _showMessage(e.message ?? 'Đã xảy ra lỗi khi đăng ký');
    } catch (e) {
      _showMessage('Lỗi hệ thống: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          L(context, 'sign_up'),
        ), // Sử dụng localization đã có của bạn
        centerTitle: true,
        backgroundColor: isDark ? Colors.grey[850] : Colors.pink[100],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color.fromRGBO(28, 28, 30, 1),
                    const Color.fromRGBO(44, 44, 46, 1),
                  ]
                : [Colors.pink.shade50, Colors.pink.shade200],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 44,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                  child: const Icon(
                    Icons.person_add_alt_1,
                    size: 44,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(height: 24),

                // Trường nhập Tên hiển thị
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Họ và tên',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 12),

                // Trường nhập Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: L(context, 'email'),
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 12),

                // Trường nhập Mật khẩu
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: L(context, 'password'),
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 12),

                // Trường nhập Xác nhận mật khẩu
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Xác nhận mật khẩu',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 24),

                // Nút Đăng ký kích hoạt logic Firebase
                ElevatedButton(
                  onPressed: _loading ? null : _signUpWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          L(context, 'sign_up'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
