import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/localization.dart';
import 'widgets/home_page.dart';
import 'screens/sign_in_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
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
      routes: {
        '/login': (context) =>
            const LoginScreen(), // Đăng ký route login để Navigator tìm thấy
      },
    );
  }
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
