import 'package:flutter/material.dart';
import '../main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'sign_up_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int _accountTabIndex = 0;
  bool _showWriteButton = false;

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
        return;
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

  Future<void> _signInWithFacebook() async {
    try {
      setState(() => _loading = true);
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success && result.accessToken != null) {
        final accessToken = result.accessToken!;
        final credential = FacebookAuthProvider.credential(accessToken.token);
        await FirebaseAuth.instance.signInWithCredential(credential);
        await _showMessage('Đăng nhập thành công với Facebook');
      } else if (result.status == LoginStatus.cancelled) {
        await _showMessage('Đã hủy đăng nhập Facebook');
      } else {
        await _showMessage('Lỗi đăng nhập Facebook');
      }
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

  void _signUpWithEmail() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
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
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('avatar_path', picked.path);
        } catch (_) {}
      }
    } catch (e) {
      await _showMessage('Không thể chọn ảnh: ${e.toString()}');
    }
  }

  void _openSettings() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.palette),
                title: Text(L(context, 'appearance')),
                onTap: () {
                  Navigator.of(ctx).pop();
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (dctx) {
                      return AlertDialog(
                        title: Text(L(context, 'choose_appearance')),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.wb_sunny),
                              title: Text(L(context, 'light')),
                              onTap: () {
                                MyApp.setAppTheme(context, ThemeMode.light);
                                Navigator.of(dctx).pop();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.nights_stay),
                              title: Text(L(context, 'dark')),
                              onTap: () {
                                MyApp.setAppTheme(context, ThemeMode.dark);
                                Navigator.of(dctx).pop();
                              },
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dctx).pop(),
                            child: Text(L(context, 'cancel')),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(L(context, 'language')),
                onTap: () {
                  Navigator.of(ctx).pop();
                  if (!mounted) return;
                  final current = MyApp.getAppLanguage(context);
                  showDialog(
                    context: context,
                    builder: (dctx) {
                      String selected = current;
                      return StatefulBuilder(
                        builder: (dctx, setStateDialog) {
                          return AlertDialog(
                            title: Text(L(context, 'language')),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: const Text('Tiếng Việt'),
                                  trailing: selected == 'vi'
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        )
                                      : const SizedBox.shrink(),
                                  onTap: () =>
                                      setStateDialog(() => selected = 'vi'),
                                ),
                                ListTile(
                                  title: const Text('English'),
                                  trailing: selected == 'en'
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        )
                                      : const SizedBox.shrink(),
                                  onTap: () =>
                                      setStateDialog(() => selected = 'en'),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(dctx).pop(),
                                child: Text(L(context, 'cancel')),
                              ),
                              TextButton(
                                onPressed: () {
                                  MyApp.setAppLanguage(context, selected);
                                  Navigator.of(dctx).pop();
                                  _showMessage('Ngôn ngữ đã được cập nhật');
                                },
                                child: Text(L(context, 'save')),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(L(context, 'account_setting')),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showMessage('Chức năng Tài khoản (tạm)');
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: Text(L(context, 'security')),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showMessage('Chức năng Bảo mật (tạm)');
                },
              ),
              const Divider(),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  tileColor: Colors.redAccent,
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: Text(
                    L(context, 'logout'),
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (dctx) => AlertDialog(
                        title: Text(L(context, 'logout_confirm_title')),
                        content: Text(L(context, 'logout_confirm_body')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dctx).pop(false),
                            child: Text(L(context, 'cancel')),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(dctx).pop(true),
                            child: Text(L(context, 'confirm')),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    if (!mounted) return;
                    Navigator.of(context).pop();
                    await FirebaseAuth.instance.signOut();
                    try {
                      await GoogleSignIn().signOut();
                    } catch (_) {}
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('avatar_path');
                      await prefs.remove('bio');
                    } catch (_) {}
                    if (!mounted) return;
                    setState(() {
                      _avatarImage = null;
                      _bio = null;
                    });
                    _showMessage(L(context, 'logout'));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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

        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
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
                  const SizedBox(height: 20),
                  const CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 48, color: Colors.pink),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    L(context, 'welcome_title'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    L(context, 'welcome_sub'),
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
                            label: Text(L(context, 'sign_in_google')),
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
                            onPressed: _signInWithFacebook,
                            icon: const Icon(
                              Icons.facebook,
                              color: Colors.white,
                            ),
                            label: Text(L(context, 'sign_in_facebook')),
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
                            label: Text(L(context, 'sign_in_apple')),
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
                            child: Text(L(context, 'sign_up')),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    L(context, 'or_use_email'),
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
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
                  ),
                  const SizedBox(height: 8),
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
                        : Text(L(context, 'sign_in')),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _sendPasswordReset,
                    child: Text(L(context, 'forgot_password')),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
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
                            ? const Icon(
                                Icons.person,
                                size: 56,
                                color: Colors.pink,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            user.displayName ?? user.email ?? 'Người dùng',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );

                            if (result == true) {
                              _loadProfileData();
                              setState(() {});
                            }
                          },
                          child: const Text("Edit"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _editBio,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 6,
                        ),
                        child: (_bio ?? '').isNotEmpty
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      _bio!,
                                      style: TextStyle(color: Colors.grey[700]),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.edit,
                                    size: 14,
                                    color: Colors.grey[500],
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    L(context, 'add_bio'),
                                    style: TextStyle(
                                      color: Colors.pink[300],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.add_comment,
                                    size: 14,
                                    color: Colors.pink[300],
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color.fromRGBO(20, 20, 20, 1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: () => setState(() {
                              _accountTabIndex = 0;
                              _showWriteButton = false;
                            }),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 40,
                                  height: 28,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: List.generate(3, (i) {
                                          return Container(
                                            width: 6,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: _accountTabIndex == 0
                                                  ? Colors.pink
                                                  : Colors.grey,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          );
                                        }),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: List.generate(3, (i) {
                                          return Container(
                                            width: 6,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: _accountTabIndex == 0
                                                  ? Colors.pink
                                                  : Colors.grey,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 3,
                                  width: 24,
                                  decoration: BoxDecoration(
                                    color: _accountTabIndex == 0
                                        ? (isDark ? Colors.white : Colors.black)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => setState(() {
                              _accountTabIndex = 1;
                              _showWriteButton = !_showWriteButton;
                            }),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.create,
                                  color: _accountTabIndex == 1
                                      ? Colors.pink
                                      : Colors.grey,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 3,
                                  width: 24,
                                  decoration: BoxDecoration(
                                    color: _accountTabIndex == 1
                                        ? (isDark ? Colors.white : Colors.black)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => setState(() {
                              _accountTabIndex = 2;
                              _showWriteButton = false;
                            }),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.favorite_border,
                                  color: _accountTabIndex == 2
                                      ? Colors.pink
                                      : Colors.grey,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 3,
                                  width: 24,
                                  decoration: BoxDecoration(
                                    color: _accountTabIndex == 2
                                        ? (isDark ? Colors.white : Colors.black)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_accountTabIndex == 0)
                      SizedBox(
                        height: 240,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.image,
                                size: 56,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Bạn chưa viết truyện nào',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_accountTabIndex == 1)
                      SizedBox(
                        height: 240,
                        child: Center(
                          child: _showWriteButton
                              ? ElevatedButton(
                                  onPressed: () {
                                    final homeState = context
                                        .findAncestorStateOfType<
                                          HomePageState
                                        >();

                                    if (homeState != null) {
                                      homeState.setState(
                                        () => homeState.currentIndex = 2,
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.pink,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 28,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: const Text('Thử viết truyện'),
                                )
                              : const SizedBox.shrink(),
                        ),
                      )
                    else
                      SizedBox(
                        height: 240,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.image,
                                size: 56,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Bạn chưa viết truyện nào',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: SafeArea(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: _openSettings,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color.fromRGBO(30, 30, 30, 0.6)
                          : const Color.fromRGBO(255, 255, 255, 0.85),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.settings,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
