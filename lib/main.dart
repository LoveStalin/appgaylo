import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/account_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setAppTheme(BuildContext context, ThemeMode mode) {
    context.findAncestorStateOfType<_MyAppState>()?.setThemeMode(mode);
  }

  static void setAppLanguage(BuildContext context, String lang) {
    context.findAncestorStateOfType<_MyAppState>()?.setLanguage(lang);
  }

  static String getAppLanguage(BuildContext context) {
    return context.findAncestorStateOfType<_MyAppState>()?.lang ?? 'vi';
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  String _lang = 'vi';

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadLanguage();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final t = prefs.getString('theme_mode') ?? 'light';
      setState(() {
        _themeMode = t == 'dark' ? ThemeMode.dark : ThemeMode.light;
      });
    } catch (_) {}
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final l = prefs.getString('app_lang') ?? 'vi';
      setState(() => _lang = l);
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'theme_mode',
        mode == ThemeMode.dark ? 'dark' : 'light',
      );
    } catch (_) {}
    if (!mounted) return;
    setState(() => _themeMode = mode);
  }

  String get lang => _lang;

  Future<void> setLanguage(String lang) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_lang', lang);
    } catch (_) {}
    if (!mounted) return;
    setState(() => _lang = lang);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Truyện Huyền Thoại",
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: Colors.pink[100]),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(backgroundColor: Colors.grey[850]),
      ),
      themeMode: _themeMode,
      home: const HomePage(),
    );
  }
}

const Map<String, Map<String, String>> _localized = {
  'vi': {
    'app_title': 'Truyện Huyền Thoại',
    'home': 'Trang chủ',
    'library': 'Thư viện',
    'write': 'Viết truyện',
    'profile': 'Trang cá nhân',
    'search_hint': 'Tìm truyện...',
    'featured': '🔥 Truyện nổi bật',
    'new': '📚 Truyện mới',
    'welcome_title': 'Chào mừng đến Truyện Huyền Thoại',
    'welcome_sub': 'Đăng nhập để tiếp tục trải nghiệm những câu chuyện thú vị',
    'sign_in_google': 'Đăng nhập với Google',
    'sign_in_facebook': 'Đăng nhập với Facebook',
    'sign_in_apple': 'Đăng nhập với Apple',
    'sign_up': 'Đăng ký tài khoản Huyền Thoại',
    'or_use_email': 'Hoặc sử dụng email của bạn',
    'email': 'Email',
    'password': 'Mật khẩu',
    'sign_in': 'Đăng nhập',
    'forgot_password': 'Quên mật khẩu hả?',
    'add_avatar': 'Thêm/Thay avatar',
    'settings': 'Cài đặt',
    'appearance': 'Giao diện',
    'language': 'Ngôn ngữ',
    'account_setting': 'Tài khoản',
    'security': 'Bảo mật',
    'logout': 'Đăng xuất',
    'logout_confirm_title': 'Xác nhận',
    'logout_confirm_body': 'Bạn có chắc muốn đăng xuất không?',
    'choose_appearance': 'Chọn giao diện',
    'light': 'Sáng',
    'dark': 'Tối',
    'cancel': 'Hủy',
    'confirm': 'Đăng xuất',
    'edit_bio': 'Chỉnh sửa Bio',
    'save': 'Lưu',
    'add_bio': 'Thêm bio',
    'welcome_back': 'Chào mừng trở lại!',
  },
  'en': {
    'app_title': 'Legend Stories',
    'home': 'Home',
    'library': 'Library',
    'write': 'Write',
    'profile': 'Profile',
    'search_hint': 'Search',
    'featured': '🔥 Featured',
    'new': '📚 New',
    'welcome_title': 'Welcome to Legend Stories',
    'welcome_sub': 'Sign in to continue enjoying great stories',
    'sign_in_google': 'Sign in with Google',
    'sign_in_facebook': 'Sign in with Facebook',
    'sign_in_apple': 'Sign in with Apple',
    'sign_up': 'Sign up for Legend',
    'or_use_email': 'Or use your email',
    'email': 'Email',
    'password': 'Password',
    'sign_in': 'Sign in',
    'forgot_password': 'Forgot password?',
    'add_avatar': 'Add/Change avatar',
    'settings': 'Settings',
    'appearance': 'Appearance',
    'language': 'Language',
    'account_setting': 'Account',
    'security': 'Security',
    'logout': 'Log out',
    'logout_confirm_title': 'Confirm',
    'logout_confirm_body': 'Are you sure you want to sign out?',
    'choose_appearance': 'Choose appearance',
    'light': 'Light',
    'dark': 'Dark',
    'cancel': 'Cancel',
    'confirm': 'Sign out',
    'edit_bio': 'Edit Bio',
    'save': 'Save',
    'add_bio': 'Add bio',
    'welcome_back': 'Welcome back!',
  },
};

String L(BuildContext context, String key) {
  final state = context.findAncestorStateOfType<_MyAppState>();
  final lang = state?.lang ?? 'vi';
  return _localized[lang]?[key] ?? key;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
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
        title: Text(L(context, 'app_title')),
        centerTitle: true,
        backgroundColor: Colors.pink[100],
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        backgroundColor: Colors.pink[100],
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: L(context, 'home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.book),
            label: L(context, 'library'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.create),
            label: L(context, 'write'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: L(context, 'profile'),
          ),
        ],
      ),
    );
  }
}
