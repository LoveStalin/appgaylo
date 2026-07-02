import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  bool _forgotPasswordSent = false;

  Future<void> _handleLogin() async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => _loading = true);
    try {
      await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      nav.pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final messenger = ScaffoldMessenger.of(context);
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Email của bạn trước!')),
      );
      return;
    }

    if (_forgotPasswordSent) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Email khôi phục đã được gửi gần đây. Vui lòng dùng email mới nhất hoặc đợi một chút rồi thử lại.',
          ),
        ),
      );
      return;
    }

    setState(() => _forgotPasswordSent = true);

    try {
      await _authService.sendPasswordResetEmail(email);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Đã gửi email đặt lại mật khẩu. Nếu link báo hết hạn, hãy gửi lại sau vài phút.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
      setState(() => _forgotPasswordSent = false);
    }

    if (!mounted) return;
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        setState(() => _forgotPasswordSent = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng nhập")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Mật khẩu"),
              ),
              const SizedBox(height: 20),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _handleForgotPassword,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.pink,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text('Quên mật khẩu?'),
                      ),
                    ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  child: const Text("Đăng nhập"),
                ),
              ),

              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                ),
                child: const Text("Chưa có tài khoản? Đăng ký ngay"),
              ),
              // Thêm các nút Social ở đây nếu muốn
              // Nút Đăng nhập Google
              ElevatedButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final nav = Navigator.of(context);
                  setState(() => _loading = true); // Hiện vòng quay loading
                  try {
                    // 1. Thực hiện đăng nhập qua AuthService
                    await _authService.signInWithGoogle();

                    // 2. "Cái khiên" bảo vệ: Kiểm tra xem người dùng còn ở màn hình Login không
                    if (!mounted) return;

                    // 3. Nếu còn, mới được phép chuyển trang
                    nav.pushNamedAndRemoveUntil('/', (route) => false);
                  } catch (e) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(content: Text("Google lỗi: $e")),
                    );
                  } finally {
                    if (mounted) setState(() => _loading = false);
                  }
                },
                icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                label: const Text("Đăng nhập bằng Google"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
              ),

              const SizedBox(height: 12),

              // Nút Đăng nhập Facebook
              ElevatedButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final nav = Navigator.of(context);
                  setState(() => _loading = true);
                  try {
                    // 1. Thực hiện đăng nhập qua AuthService
                    await _authService.signInWithFacebook();

                    // 2. "Cái khiên" bảo vệ
                    if (!mounted) return;

                    // 3. Chuyển trang an toàn
                    nav.pushNamedAndRemoveUntil('/', (route) => false);
                  } catch (e) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(content: Text("Facebook lỗi: $e")),
                    );
                  } finally {
                    if (mounted) setState(() => _loading = false);
                  }
                },
                icon: const Icon(Icons.facebook, color: Colors.white),
                label: const Text("Đăng nhập bằng Facebook"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
