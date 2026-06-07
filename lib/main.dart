import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Truyện Huyền Thoại",
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    Center(child: Text("Thư viện")),
    Center(child: Text("Viết truyện")),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Truyện Huyền Thoại"),
        centerTitle: true,
        backgroundColor: Colors.pink[100], // hồng pastel
      ),

      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        backgroundColor: Colors.pink[100], // hồng pastel

        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),

          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Thư viện"),

          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: "Viết truyện",
          ),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Tài khoản"),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // thanh tìm kiếm
        TextField(
          decoration: InputDecoration(
            hintText: "Tìm truyện...",
            prefixIcon: Icon(Icons.search),
            filled: true,
            fillColor: Colors.pink[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          "🔥 Truyện nổi bật",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [StoryCard(), StoryCard(), StoryCard()],
        ),

        const SizedBox(height: 20),

        const Text(
          "📚 Truyện mới",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

//Account Screen
//Account Screen
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  File? _avatarImage;
  String? _bio;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _editBio() async {
    final controller = TextEditingController(text: _bio ?? '');
    if (!mounted) return;
    final res = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chỉnh sửa Bio'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Viết điều gì đó về bạn'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (res != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bio', res);
      if (!mounted) return;
      setState(() => _bio = res);
      await _showMessage('Bio đã được cập nhật');
    }
  }

  Future<void> _loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bio = prefs.getString('bio');
      final avatarPath = prefs.getString('avatar_path');
      File? avatar;
      if (avatarPath != null && avatarPath.isNotEmpty) {
        final f = File(avatarPath);
        if (await f.exists()) avatar = f;
      }
      setState(() {
        _bio = bio;
        _avatarImage = avatar;
      });
    } catch (_) {}
  }

  Future<void> _showMessage(String message) async {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() => _loading = true);
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _loading = false);
        return; // user canceled
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      await _showMessage('Đăng nhập thành công với Google');
    } catch (e) {
      await _showMessage('Lỗi: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signInWithEmail() async {
    try {
      setState(() => _loading = true);
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await _showMessage('Đăng nhập thành công');
    } on FirebaseAuthException catch (e) {
      await _showMessage(e.message ?? 'Lỗi đăng nhập');
    } catch (e) {
      await _showMessage('Lỗi: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signUpWithEmail() async {
    try {
      setState(() => _loading = true);
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await _showMessage('Đăng ký thành công');
    } on FirebaseAuthException catch (e) {
      await _showMessage(e.message ?? 'Lỗi đăng ký');
    } catch (e) {
      await _showMessage('Lỗi: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      await _showMessage('Đã gửi email đặt lại mật khẩu');
    } on FirebaseAuthException catch (e) {
      await _showMessage(e.message ?? 'Lỗi');
    } catch (e) {
      await _showMessage('Lỗi: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user != null) {
          return _buildProfile(user);
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.pink.shade50, Colors.pink.shade200],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  const CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 48, color: Colors.pink),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'Chào mừng đến Truyện Huyền Thoại',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Đăng nhập để tiếp tục trải nghiệm những câu chuyện thú vị',
                    style: TextStyle(color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _signInWithGoogle,
                            icon: const Icon(
                              Icons.g_mobiledata,
                              color: Colors.white,
                            ),
                            label: const Text('Đăng nhập với Google'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.facebook,
                              color: Colors.white,
                            ),
                            label: const Text('Đăng nhập với Facebook'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent.shade700,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.apple, color: Colors.white),
                            label: const Text('Đăng nhập với Apple'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextButton(
                            onPressed: _signUpWithEmail,
                            child: const Text('Đăng ký tài khoản Huyền Thoại'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Hoặc sử dụng email của bạn',
                    style: TextStyle(color: Colors.black54),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Mật khẩu',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: _loading ? null : _signInWithEmail,
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
                        : const Text('Đăng nhập'),
                  ),

                  const SizedBox(height: 24),

                  TextButton(
                    onPressed: _sendPasswordReset,
                    child: const Text('Quên mật khẩu hả?'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfile(User user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.pink.shade50, Colors.pink.shade200],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickAvatar,
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: Colors.white,
                  backgroundImage: _avatarImage != null
                      ? FileImage(_avatarImage!) as ImageProvider
                      : (user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : null),
                  child: _avatarImage == null && user.photoURL == null
                      ? const Icon(Icons.person, size: 56, color: Colors.pink)
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user.displayName ?? user.email ?? 'Người dùng',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if ((_bio ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _bio!,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      IconButton(
                        onPressed: _editBio,
                        icon: const Icon(Icons.edit, size: 18),
                        tooltip: 'Chỉnh sửa bio',
                      ),
                    ],
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Chào mừng trở lại!',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _editBio,
                      icon: const Icon(Icons.add, size: 18),
                      tooltip: 'Thêm bio',
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickAvatar,
                icon: const Icon(Icons.photo_camera),
                label: const Text('Thêm/Thay avatar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  try {
                    await GoogleSignIn().signOut();
                  } catch (_) {}
                  setState(() => _avatarImage = null);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Đăng xuất'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (file != null) {
        final picked = File(file.path);
        setState(() => _avatarImage = picked);
        // persist avatar path locally
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('avatar_path', picked.path);
        } catch (_) {}
      }
    } catch (e) {
      await _showMessage('Không thể chọn ảnh: ${e.toString()}');
    }
  }
}
