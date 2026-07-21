import 'package:flutter/material.dart';
import '../widgets/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'sign_in_screen.dart';
import '../widgets/profile_header.dart';
import '../widgets/account_tabs_bar.dart';
import '../widgets/account_tab_content.dart';
import '../widgets/settings_menu.dart';
import '../widgets/settings_button.dart';
import '../widgets/account_screen_background.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthService _authService = AuthService();

  File? _avatarImage;
  String? _bio;
  int _accountTabIndex = 0;
  bool _showWriteButton = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
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

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _authService.currentUser;

    // If not logged in, show login screen
    if (currentUser == null) {
      return const LoginScreen();
    }

    // If logged in, show profile
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AccountScreenBackground(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Header
                  ProfileHeader(
                    user: currentUser,
                    bio: _bio,
                    avatarImage: _avatarImage,
                    onAvatarChanged: () {
                      _loadProfileData();
                    },
                    onBioChanged: (newBio) {
                      setState(() => _bio = newBio);
                    },
                  ),
                  const SizedBox(height: 20),
                  // Account Tabs
                  AccountTabsBar(
                    selectedIndex: _accountTabIndex,
                    onTabChanged: (index) {
                      setState(() {
                        _accountTabIndex = index;
                        if (index == 1) {
                          _showWriteButton = !_showWriteButton;
                        } else {
                          _showWriteButton = false;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Tab Content
                  AccountTabContent(
                    tabIndex: _accountTabIndex,
                    onWriteButtonPressed: () {
                      final homeState = context
                          .findAncestorStateOfType<HomePageState>();

                      if (homeState != null) {
                        homeState.setState(() => homeState.currentIndex = 2);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Settings Button
          SettingsButton(
            onPressed: () {
              SettingsMenu.show(context: context, authService: _authService);
            },
          ),
        ],
      ),
    );
  }
}
