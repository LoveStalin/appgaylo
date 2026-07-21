import 'package:flutter/material.dart';
import '../l10n/localization.dart';
import 'email_verification_screen.dart';
import '../services/auth_service.dart'; // Import service đã tách

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

  // 1. Khai báo service ở đây
  final AuthService _authService = AuthService();
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

  // 2. Sửa hàm này để khớp với AuthService
  Future<void> _signUpWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (_nameController.text.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage("Vui lòng điền đủ thông tin");
      return;
    }

    if (password != confirmPassword) {
      _showMessage("Mật khẩu không khớp!");
      return;
    }

    setState(() => _loading = true);

    try {
      // Dùng service thay cho FirebaseAuth trực tiếp
      await _authService.signUp(email, password);
      await _authService.sendVerificationEmail();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EmailVerificationScreen(email: email),
        ),
      );
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI của m vẫn giữ nguyên từ đầu đến cuối
    return Scaffold(
      appBar: AppBar(title: Text(L(context, 'sign_up'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Họ tên"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Mật khẩu"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Nhập lại mật khẩu"),
            ),
            const SizedBox(height: 24),

            // Nút bấm này gọi hàm _signUpWithEmail đã sửa ở trên
            ElevatedButton(
              onPressed: _loading ? null : _signUpWithEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(L(context, 'sign_up')),
            ),
          ],
        ),
      ),
    );
  }
}
