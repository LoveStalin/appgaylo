import 'package:flutter/material.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../screens/sign_in_screen.dart';
import '../l10n/localization.dart';

class SettingsMenu {
  static Future<void> show({
    required BuildContext context,
    required AuthService authService,
  }) async {
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
                  _showThemeDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(L(context, 'language')),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showLanguageDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(L(context, 'account_setting')),
                onTap: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng Tài khoản (tạm)')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: Text(L(context, 'security')),
                onTap: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng Bảo mật (tạm)')),
                  );
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
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.of(ctx).pop();

                    try {
                      await authService.signOut();
                    } catch (e) {
                      if (!context.mounted) return;
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Lỗi đăng xuất: ${e.toString()}'),
                        ),
                      );
                      return;
                    }

                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _showThemeDialog(BuildContext context) async {
    if (!context.mounted) return;
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
  }

  static Future<void> _showLanguageDialog(BuildContext context) async {
    if (!context.mounted) return;
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
                        ? const Icon(Icons.check, color: Colors.green)
                        : const SizedBox.shrink(),
                    onTap: () => setStateDialog(() => selected = 'vi'),
                  ),
                  ListTile(
                    title: const Text('English'),
                    trailing: selected == 'en'
                        ? const Icon(Icons.check, color: Colors.green)
                        : const SizedBox.shrink(),
                    onTap: () => setStateDialog(() => selected = 'en'),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ngôn ngữ đã được cập nhật'),
                      ),
                    );
                  },
                  child: Text(L(context, 'save')),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
