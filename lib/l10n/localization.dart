import 'package:flutter/material.dart';

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

/// Get localized string by key
String L(BuildContext context, String key) {
  try {
    // Try to find the state - the type doesn't matter for the lookup
    final state = context.findAncestorStateOfType<State>();
    if (state != null && state.mounted) {
      // Access lang property dynamically
      final lang = (state as dynamic).lang ?? 'vi';
      return _localized[lang]?[key] ?? key;
    }
  } catch (_) {}
  return _localized['vi']?[key] ?? key;
}
